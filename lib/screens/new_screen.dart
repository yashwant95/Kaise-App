import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/video_card.dart';
import 'video_details_screen.dart';
import '../services/api_service.dart';
import '../models/course.dart';

class NewScreen extends StatefulWidget {
  const NewScreen({super.key});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  int _selectedFilterIndex = 0;
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final courses = await ApiService.fetchCourses();
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching courses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterCategories = [
      'All',
      'Youtube',
      'Instagram',
      'Business',
      'Editing'
    ];

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
          const SizedBox(height: 15),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filterCategories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedFilterIndex;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.white : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Center(
                        child: Text(
                          filterCategories[index],
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
                      context, 'Trending this Week', _courses),
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
      BuildContext context, String title, List courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('See all trending coming soon!')));
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
              // Sanitize title for tag to avoid space/special char usage if needed, though Hero supports strings.
              // We use heading + id for uniqueness.
              final sectionPrefix = title.replaceAll(' ', '');
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: SizedBox(
                  width: 140,
                  child: VideoCard(
                    video: {'title': course.title, 'tag': course.tag},
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
