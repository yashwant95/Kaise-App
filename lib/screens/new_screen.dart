import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/video_card.dart';
import 'video_details_screen.dart';
import 'video_list_screen.dart';
import '../services/api_service.dart';
import '../models/course.dart';

class NewScreen extends StatefulWidget {
  const NewScreen({super.key});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  List<Course> _courses = [];
  List<Course> _trendingThisWeek = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final courses = await ApiService.fetchCourses();
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final weeklyCourses = courses
          .where((course) =>
              course.createdAt != null && course.createdAt!.isAfter(weekAgo))
          .toList()
        ..sort((a, b) => b.viewCount.compareTo(a.viewCount));

      final trending = weeklyCourses.isNotEmpty
          ? weeklyCourses.take(9).toList()
          : ([...courses]..sort((a, b) => b.viewCount.compareTo(a.viewCount)))
              .take(9)
              .toList();

      setState(() {
        _courses = courses;
        _trendingThisWeek = trending;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching courses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.amber));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'New Arrivals',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchCourses,
              color: Colors.amber,
              backgroundColor: const Color(0xFF1E1E1E),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                children: [
                  _buildNewArrivalSection(
                      context, 'Trending this Week', _trendingThisWeek),
                  _buildNewArrivalSection(context, 'Newly Added Series',
                      _courses.reversed.toList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewArrivalSection(
      BuildContext context, String title, List<Course> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoListScreen(
                  title: title,
                  courses: courses,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: courses.length,
            itemBuilder: (context, i) {
              final course = courses[i];
              final sectionPrefix = title.replaceAll(' ', '');
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: SizedBox(
                  width: 140,
                  child: VideoCard(
                    video: {'title': course.title},
                    imageUrl: course.seriesThumbnail,
                    heroTag: 'new_${sectionPrefix}_${course.id}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoDetailsScreen(
                                  course: course,
                                  heroTag: 'new_${sectionPrefix}_${course.id}',
                                )),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
