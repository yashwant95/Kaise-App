import 'package:flutter/material.dart';

import '../models/course.dart';
import 'video_details_screen.dart';

class AppVideosScreen extends StatefulWidget {
  final String categoryLabel;
  final List<Course> apps;
  final Course initialApp;

  const AppVideosScreen({
    super.key,
    required this.categoryLabel,
    required this.apps,
    required this.initialApp,
  });

  @override
  State<AppVideosScreen> createState() => _AppVideosScreenState();
}

class _AppVideosScreenState extends State<AppVideosScreen> {
  late Course _selectedApp;

  @override
  void initState() {
    super.initState();
    _selectedApp = widget.initialApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.categoryLabel),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Wrap(
              spacing: 14,
              runSpacing: 12,
              children: widget.apps.map((app) {
                final isSelected = app.id == _selectedApp.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedApp = app),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.white54,
                        width: isSelected ? 2.4 : 1.3,
                      ),
                      color: Colors.white.withOpacity(0.04),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      app.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              '${_selectedApp.title} Videos',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1,
              ),
              itemCount: _selectedApp.episodes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoDetailsScreen(course: _selectedApp),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white70, width: 1.2),
                      color: Colors.white.withOpacity(0.03),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
