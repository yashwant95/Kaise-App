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
    return Column(
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(
            'History',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.amber,
            ),
          ),
        ),
        Expanded(
          child: _buildHistoryList(context),
        ),
      ],
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
            return EpisodeTile(
              episode: {
                'title': 'Watching: ${course.title}',
                'date': 'Yesterday',
                'duration': '',
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
}
