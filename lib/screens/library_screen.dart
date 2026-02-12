import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/episode_tile.dart';
import '../data/mock_data.dart';
import 'video_details_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Future<void> _handleRefresh() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              'My Library',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const TabBar(
            isScrollable: true,
            indicatorColor: Colors.amber,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'History'),
              Tab(text: 'Saved'),
              Tab(text: 'Downloads'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildHistoryList(context),
                _buildSavedList(context),
                _buildDownloadsPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.amber,
        backgroundColor: const Color(0xFF1E1E1E),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          itemCount: allCourses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final course = allCourses[index];
            final episode = course.episodes.first;
            return EpisodeTile(
              episode: {
                'title': 'Watching: ${course.title}',
                'date': 'Yesterday',
                'duration': episode.duration,
                'isNew': false,
              },
              imageUrl: course.seriesThumbnail,
              heroTag: 'library_history_${course.id}',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoDetailsScreen(
                            course: course,
                            heroTag: 'library_history_${course.id}',
                          )),
                );
              },
            );
          },
        ));
  }

  Widget _buildSavedList(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.amber,
        backgroundColor: const Color(0xFF1E1E1E),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          itemCount: allCourses.length,
          itemBuilder: (context, index) {
            final course = allCourses[index];
            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.3),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoDetailsScreen(
                              course: course,
                              heroTag: 'library_saved_${course.id}',
                            )),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Hero(
                          tag: 'library_saved_${course.id}',
                          child: Image.network(
                            course.seriesThumbnail,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8)
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text('${course.episodes.length} Episodes',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget _buildDownloadsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_for_offline_outlined,
              size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No Downloads Yet',
            style: TextStyle(
                color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep videos offline to watch later',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
