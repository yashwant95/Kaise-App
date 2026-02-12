import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/course.dart';
import '../widgets/episode_tile.dart';
import '../services/api_service.dart';

class VideoDetailsScreen extends StatefulWidget {
  final Course course;
  final String? heroTag;
  const VideoDetailsScreen({super.key, required this.course, this.heroTag});

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen>
    with SingleTickerProviderStateMixin {
  YoutubePlayerController? _controller;
  late Episode _currentEpisode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Fullscreen state
  bool _isFullscreen = false;

  // Key to force rebuild of YoutubePlayer when needed
  UniqueKey _playerKey = UniqueKey();

  // AdMob
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isLoadingAd = false;
  bool _hasShownAdForVideoEnd = false;

  // Double-tap seek feedback
  bool _showSeekForward = false;
  bool _showSeekBackward = false;
  Timer? _seekForwardTimer;
  Timer? _seekBackwardTimer;

  // AdMob Ad Unit IDs
  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4207496413059718/7285068698';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4207496413059718/7285068698';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _setPortraitMode();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _currentEpisode = widget.course.episodes.first;
    _loadInterstitialAd();
    // Increment view count when course is opened
    ApiService.incrementViewCount(widget.course.id);
  }

  /// Extracts a YouTube video ID from a full URL or returns the ID as-is.
  String _extractYoutubeId(String url) {
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url)) return url;
    final patterns = [
      RegExp(
          r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/|youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})'),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.group(1) != null) return match.group(1)!;
    }
    return url;
  }

  void _initializeController(String videoUrl) {
    final videoId = _extractYoutubeId(videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        forceHD: false,
        hideControls: false,
      ),
    );
    _controller!.addListener(_onPlayerStateChange);
  }

  void _setPortraitMode() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _setFullscreenMode() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _loadInterstitialAd() {
    if (_isLoadingAd) return;
    _isLoadingAd = true;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: ${error.message}');
          _isLoadingAd = false;
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  void _showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          _loadInterstitialAd();
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          _loadInterstitialAd();
          onAdClosed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      onAdClosed?.call();
    }
  }

  void _onPlayerStateChange() {
    if (_controller == null) return;

    // When video ends: show ad, then auto-play next episode
    if (_controller!.value.playerState == PlayerState.ended &&
        !_hasShownAdForVideoEnd) {
      _hasShownAdForVideoEnd = true;

      // Show ad first, then play next episode after ad closes
      _showInterstitialAd(onAdClosed: () {
        if (mounted) {
          _autoPlayNextEpisode();
        }
      });
    }

    if (_controller!.value.playerState == PlayerState.playing) {
      _hasShownAdForVideoEnd = false;
    }
  }

  /// Automatically plays the next episode after ad finishes.
  /// If no next episode, exits fullscreen.
  void _autoPlayNextEpisode() {
    final currentIndex =
        widget.course.episodes.indexWhere((ep) => ep.id == _currentEpisode.id);

    if (currentIndex != -1 &&
        currentIndex < widget.course.episodes.length - 1) {
      final nextEpisode = widget.course.episodes[currentIndex + 1];
      _switchToEpisode(nextEpisode);
    } else {
      // No more episodes, exit fullscreen
      _exitFullscreen();
    }
  }

  /// Seek forward by 10 seconds
  void _seekForward() {
    if (_controller == null) return;
    final currentPos = _controller!.value.position;
    final newPos = currentPos + const Duration(seconds: 10);
    _controller!.seekTo(newPos);

    // Show visual feedback
    _seekForwardTimer?.cancel();
    setState(() => _showSeekForward = true);
    _seekForwardTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showSeekForward = false);
    });
  }

  /// Seek backward by 10 seconds
  void _seekBackward() {
    if (_controller == null) return;
    final currentPos = _controller!.value.position;
    final newPos = currentPos - const Duration(seconds: 10);
    _controller!.seekTo(newPos.isNegative ? Duration.zero : newPos);

    // Show visual feedback
    _seekBackwardTimer?.cancel();
    setState(() => _showSeekBackward = true);
    _seekBackwardTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showSeekBackward = false);
    });
  }

  void _playEpisode(Episode episode) {
    // Dispose existing controller
    if (_controller != null) {
      _controller!.removeListener(_onPlayerStateChange);
      _controller!.dispose();
      _controller = null;
    }

    setState(() {
      _currentEpisode = episode;
      _hasShownAdForVideoEnd = false;
    });

    _initializeController(episode.videoUrl);

    setState(() {
      _playerKey = UniqueKey(); // Force rebuild with new controller
    });

    // Enter fullscreen mode to play the video
    _enterFullscreen();
  }

  void _playNextEpisode() {
    final currentIndex =
        widget.course.episodes.indexWhere((ep) => ep.id == _currentEpisode.id);
    if (currentIndex != -1 &&
        currentIndex < widget.course.episodes.length - 1) {
      final nextEpisode = widget.course.episodes[currentIndex + 1];
      _switchToEpisode(nextEpisode);
    }
  }

  void _playPreviousEpisode() {
    final currentIndex =
        widget.course.episodes.indexWhere((ep) => ep.id == _currentEpisode.id);
    if (currentIndex > 0) {
      final previousEpisode = widget.course.episodes[currentIndex - 1];
      _switchToEpisode(previousEpisode);
    }
  }

  void _switchToEpisode(Episode episode) {
    if (_controller != null) {
      _controller!.removeListener(_onPlayerStateChange);
      _controller!.dispose();
      _controller = null;
    }

    setState(() {
      _currentEpisode = episode;
      _hasShownAdForVideoEnd = false;
    });

    _initializeController(episode.videoUrl);

    setState(() {
      _playerKey = UniqueKey();
    });
  }

  void _enterFullscreen() {
    setState(() {
      _isFullscreen = true;
    });
    _setFullscreenMode();
  }

  void _exitFullscreen() {
    _setPortraitMode();

    setState(() {
      _isFullscreen = false;
    });

    // Clean up controller when exiting fullscreen
    if (_controller != null) {
      _controller!.removeListener(_onPlayerStateChange);
      _controller!.pause();
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _seekForwardTimer?.cancel();
    _seekBackwardTimer?.cancel();
    if (_controller != null) {
      _controller!.removeListener(_onPlayerStateChange);
      _controller!.dispose();
    }
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _animationController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If in fullscreen mode, show fullscreen player
    if (_isFullscreen) {
      return _buildFullscreenPlayer();
    }

    // Normal mode
    return _buildNormalView();
  }

  Widget _buildFullscreenPlayer() {
    if (_controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _exitFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Video Player - Full screen centered
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: YoutubePlayer(
                  key: _playerKey,
                  controller: _controller!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.amber,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.amber,
                    handleColor: Colors.amberAccent,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.white12,
                  ),
                  bottomActions: [
                    const SizedBox(width: 14),
                    const CurrentPosition(),
                    const SizedBox(width: 8),
                    const ProgressBar(isExpanded: true),
                    const SizedBox(width: 8),
                    const RemainingDuration(),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ),

            // Double-tap seek zones (left = backward, right = forward)
            Positioned.fill(
              child: Row(
                children: [
                  // Left half - double tap to seek backward 10s
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onDoubleTap: _seekBackward,
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity != null &&
                            details.primaryVelocity! > 500) {
                          _playPreviousEpisode();
                        } else if (details.primaryVelocity != null &&
                            details.primaryVelocity! < -500) {
                          _playNextEpisode();
                        }
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // Right half - double tap to seek forward 10s
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onDoubleTap: _seekForward,
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity != null &&
                            details.primaryVelocity! > 500) {
                          _playPreviousEpisode();
                        } else if (details.primaryVelocity != null &&
                            details.primaryVelocity! < -500) {
                          _playNextEpisode();
                        }
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),

            // Seek backward visual feedback
            if (_showSeekBackward)
              Positioned(
                left: 40,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showSeekBackward ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.replay_10, color: Colors.white, size: 40),
                          SizedBox(height: 4),
                          Text('10s',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Seek forward visual feedback
            if (_showSeekForward)
              Positioned(
                right: 40,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showSeekForward ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.forward_10, color: Colors.white, size: 40),
                          SizedBox(height: 4),
                          Text('10s',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 12,
              child: GestureDetector(
                onTap: _exitFullscreen,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Episode title overlay at top
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 60,
              child: Text(
                _currentEpisode.title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalView() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.course.title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEpisodeHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) setState(() {});
                  },
                  color: Colors.amber,
                  backgroundColor: const Color(0xFF1E1E1E),
                  child: _buildEpisodesList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Episodes',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${widget.course.episodes.length} episodes',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodesList() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: widget.course.episodes.length,
      itemBuilder: (context, index) {
        final ep = widget.course.episodes[index];
        final isPlaying = ep.id == _currentEpisode.id;

        return GestureDetector(
          onTap: () => _playEpisode(ep),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPlaying
                    ? Colors.amber.withOpacity(0.5)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    ep.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[850]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  // Play button overlay if playing
                  if (isPlaying)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  // Title overlay at bottom
                  Positioned(
                    bottom: 12,
                    left: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${index + 1}. ${ep.title}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (ep.isNew) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'New',
                              style: TextStyle(
                                color: Color(0xFFB388FF),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
