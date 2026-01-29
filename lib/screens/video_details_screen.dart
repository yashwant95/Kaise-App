import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/course.dart';
import '../widgets/episode_tile.dart';

class VideoDetailsScreen extends StatefulWidget {
  final Course course;
  final String? heroTag;
  const VideoDetailsScreen({super.key, required this.course, this.heroTag});

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  late YoutubePlayerController _controller;
  late Episode _currentEpisode;

  @override
  void initState() {
    super.initState();
    _forcePortrait();
    _currentEpisode = widget.course.episodes.first;
    _controller = YoutubePlayerController(
      initialVideoId: _currentEpisode.videoUrl,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  void _playEpisode(Episode episode) {
    setState(() {
      _currentEpisode = episode;
      _controller.load(episode.videoUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        aspectRatio: 9 / 16,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.amber,
        bottomActions: [
          const CurrentPosition(),
          const SizedBox(width: 8),
          const ProgressBar(isExpanded: true),
          const RemainingDuration(),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            color: Colors.white,
            onPressed: _openPortraitFullscreen,
          ),
        ],
        onReady: () => _controller.addListener(() {}),
      ),
      builder: (context, player) {
        final playerWithButton = Stack(
          children: [
            player,
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: _openPortraitFullscreen,
              ),
            ),
          ],
        );

        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: playerWithButton,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.course.isFree
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.course.isFree ? 'FREE' : 'PREMIUM',
                              style: TextStyle(
                                color: widget.course.isFree
                                    ? Colors.green
                                    : Colors.redAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' ${widget.course.rating} (${widget.course.reviewsCount} reviews)',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.course.title,
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.course.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildPlayMainButton(),
                      const SizedBox(height: 32),
                      _buildEpisodeHeader(),
                      const SizedBox(height: 16),
                      _buildEpisodesList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayMainButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () => _controller.play(),
        icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
        label: const Text(
          'Continue Watching',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildEpisodeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'All Episodes (${widget.course.episodes.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Icon(Icons.sort, color: Colors.white70),
      ],
    );
  }

  Widget _buildEpisodesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: widget.course.episodes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final ep = widget.course.episodes[index];
        final isPlaying = ep.id == _currentEpisode.id;

        return EpisodeTile(
          episode: {
            'title': ep.title,
            'date': ep.date,
            'duration': ep.duration,
            'isNew': ep.isNew,
          },
          imageUrl: ep.thumbnailUrl,
          onTap: () => _playEpisode(ep),
        );
      },
    );
  }

  void _forcePortrait({bool immersive = false}) {
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      immersive ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _openPortraitFullscreen() async {
    _forcePortrait(immersive: true);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: YoutubePlayer(
                      controller: _controller,
                      aspectRatio: 9 / 16,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.amber,
                      bottomActions: const [
                        CurrentPosition(),
                        SizedBox(width: 8),
                        ProgressBar(isExpanded: true),
                        RemainingDuration(),
                      ],
                      onReady: () {
                        _controller.play();
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    _forcePortrait(immersive: false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }
}
