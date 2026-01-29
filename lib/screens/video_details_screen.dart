import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/course.dart';
import '../widgets/episode_tile.dart';

class VideoDetailsScreen extends StatefulWidget {
  final Course course;
  final String? heroTag;
  const VideoDetailsScreen({super.key, required this.course, this.heroTag});

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen>
    with SingleTickerProviderStateMixin {
  late YoutubePlayerController _controller;
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

  // AdMob Test IDs
  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
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
    _initializeController(_currentEpisode.videoUrl);
    _loadInterstitialAd();
  }

  void _initializeController(String videoId) {
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
    _controller.addListener(_onPlayerStateChange);
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
          
          // Rebuild player after ad closes to fix WebView issues
          if (mounted) {
            _rebuildPlayer();
          }
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

  void _rebuildPlayer() {
    if (!mounted) return;
    
    final currentVideoId = _currentEpisode.videoUrl;
    final currentPosition = _controller.value.position;
    
    // Clean up old controller
    _controller.removeListener(_onPlayerStateChange);
    _controller.pause();
    
    // Dispose old controller
    _controller.dispose();
    
    // Create new controller
    _controller = YoutubePlayerController(
      initialVideoId: currentVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        forceHD: false,
        hideControls: false,
      ),
    );
    _controller.addListener(_onPlayerStateChange);
    
    // Update key to force rebuild
    setState(() {
      _playerKey = UniqueKey();
    });
    
    // Seek to previous position after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && currentPosition.inSeconds > 2) {
        _controller.seekTo(currentPosition);
      }
    });
  }

  void _onPlayerStateChange() {
    if (_controller.value.playerState == PlayerState.ended &&
        !_hasShownAdForVideoEnd &&
        !_isFullscreen) {
      _hasShownAdForVideoEnd = true;
      _showInterstitialAd();
    }
    if (_controller.value.playerState == PlayerState.playing) {
      _hasShownAdForVideoEnd = false;
    }
  }

  void _playEpisode(Episode episode) {
    if (_currentEpisode.id == episode.id) {
      _controller.play();
      return;
    }

    // Recreate controller for new episode
    _controller.removeListener(_onPlayerStateChange);
    _controller.pause();
    
    setState(() {
      _currentEpisode = episode;
      _hasShownAdForVideoEnd = false;
    });
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      _controller.dispose();
      
      _controller = YoutubePlayerController(
        initialVideoId: episode.videoUrl,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
          forceHD: false,
          hideControls: false,
        ),
      );
      _controller.addListener(_onPlayerStateChange);
      
      setState(() {
        _playerKey = UniqueKey(); // Force rebuild with new controller
      });
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
    
    // Show ad when exiting fullscreen (only if not already shown for video end)
    if (!_hasShownAdForVideoEnd) {
      _showInterstitialAd();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerStateChange);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _animationController.dispose();
    _controller.dispose();
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
                  controller: _controller,
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
          ],
        ),
      ),
    );
  }

  Widget _buildNormalView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.width * 9 / 16,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: widget.heroTag ?? widget.course.id,
          child: Material(
            color: Colors.black,
            child: Stack(
              children: [
                // Video Player
                YoutubePlayer(
                  key: _playerKey,
                  controller: _controller,
                  aspectRatio: 16 / 9,
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
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white, size: 28),
                      onPressed: _enterFullscreen,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseInfo(),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 28),
          _buildNowPlaying(),
          const SizedBox(height: 24),
          _buildEpisodeHeader(),
          const SizedBox(height: 16),
          _buildEpisodesList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _buildTag(
              widget.course.isFree ? 'FREE' : 'PREMIUM',
              widget.course.isFree ? Colors.green : Colors.redAccent,
            ),
            _buildTag(widget.course.tag, Colors.amber),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.course.title,
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < widget.course.rating.floor()
                    ? Icons.star
                    : (index < widget.course.rating
                        ? Icons.star_half
                        : Icons.star_border),
                color: Colors.amber,
                size: 18,
              );
            }),
            const SizedBox(width: 8),
            Text(
              '${widget.course.rating}',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${widget.course.reviewsCount} reviews)',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.course.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.bookmark_border,
            label: 'Save',
            isPrimary: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Course saved!')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.download_outlined,
            label: 'Download',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download feature coming soon!')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.amber : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? Colors.amber : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.black : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNowPlaying() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.15),
            Colors.amber.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.play_circle_fill,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentEpisode.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _currentEpisode.duration,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ],
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: widget.course.episodes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ep = widget.course.episodes[index];
        final isPlaying = ep.id == _currentEpisode.id;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color:
                isPlaying ? Colors.amber.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPlaying
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: EpisodeTile(
            episode: {
              'title': '${index + 1}. ${ep.title}',
              'date': ep.date,
              'duration': ep.duration,
              'isNew': ep.isNew,
            },
            imageUrl: ep.thumbnailUrl,
            isPlaying: isPlaying,
            onTap: () => _playEpisode(ep),
          ),
        );
      },
    );
  }
}
