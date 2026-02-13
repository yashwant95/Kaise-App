import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/category_item.dart';
import '../widgets/video_card.dart';
import '../models/course.dart';
import '../models/category.dart';

import 'video_details_screen.dart';
import 'new_screen.dart';
import 'library_screen.dart';
import 'coach_screen.dart';
import 'profile_screen.dart';

import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _selectedCategory;
  String _searchQuery = '';
  List<Course> _courses = [];
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final courses = await ApiService.fetchCourses();
      final categories = await ApiService.fetchCategories();
      setState(() {
        _courses = courses;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching data: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.amber))
                : _HomeDashboard(
                    selectedCategory: _selectedCategory,
                    searchQuery: _searchQuery,
                    courses: _courses,
                    categories: _categories,
                    onCategorySet: (cat) =>
                        setState(() => _selectedCategory = cat),
                    onSearchSet: (query) =>
                        setState(() => _searchQuery = query),
                  ),
            const NewScreen(),
            const LibraryScreen(),
            const CoachScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department_rounded), label: 'New'),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_library_rounded), label: 'My Library'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded), label: 'Coach'),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatefulWidget {
  final String? selectedCategory;
  final String searchQuery;
  final List<Course> courses;
  final List<Category> categories;
  final Function(String?)? onCategorySet;
  final Function(String)? onSearchSet;

  const _HomeDashboard({
    required this.courses,
    required this.categories,
    this.selectedCategory,
    this.searchQuery = '',
    this.onCategorySet,
    this.onSearchSet,
  });

  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  static const String _englishSpeakingCategory = 'English Speaking';
  List<Course> _searchResults = [];
  bool _isSearching = false;
  bool _isSearchLoading = false;

  @override
  void didUpdateWidget(_HomeDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _performSearch(widget.searchQuery);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _isSearchLoading = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchLoading = true;
    });

    try {
      final results = await ApiService.searchCourses(query);
      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _isSearchLoading = false;
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // Use search results if searching, otherwise use filtered courses
    List<Course> displayCourses;
    if (_isSearching && widget.searchQuery.isNotEmpty) {
      displayCourses = _searchResults;
    } else {
      displayCourses = widget.courses.where((course) {
        final matchesCategory = widget.selectedCategory == null ||
            course.category == widget.selectedCategory;
        final matchesSearch = widget.searchQuery.isEmpty ||
            course.title
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: CustomSearchBar(
              hint: localizations.searchHint,
              onChanged: (value) {
                widget.onSearchSet?.call(value);
              },
            ),
          ),
          const SizedBox(height: 20),
          if (widget.searchQuery.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                localizations.searchResultsFor(widget.searchQuery),
                style: const TextStyle(
                    color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          if (_isSearchLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            )
          else
            _buildSectionHeader(
              icon: Icons.bar_chart,
              title: displayCourses.isEmpty
                  ? localizations.noResults
                  : localizations.topVideos,
              iconColor: Colors.blueAccent,
            ),
          const SizedBox(height: 16),
          _buildTopVideosGrid(context, displayCourses),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageProvider = context.read<LanguageProvider>();
    final selectedCode = languageProvider.locale.languageCode;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.languageSelectTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLanguageTile(
                  context: context,
                  label: localizations.languageEnglish,
                  locale: const Locale('en'),
                  isSelected: selectedCode == 'en',
                ),
                _buildLanguageTile(
                  context: context,
                  label: localizations.languageHindi,
                  locale: const Locale('hi'),
                  isSelected: selectedCode == 'hi',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String label,
    required Locale locale,
    required bool isSelected,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? Colors.amber : Colors.white54,
      ),
      onTap: () async {
        await context.read<LanguageProvider>().setLocale(locale);
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Logo
          Image.asset(
            'assets/images/app_logo.png',
            height: 40,
            width: 40,
          ),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showLanguagePicker(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withOpacity(0.1),
                          Colors.blue.withOpacity(0.1)
                        ],
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Text(
                          localizations.languageChipLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 18, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF2A2A2A),
                    child: Icon(Icons.person, color: Colors.white70, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    // Helper to map string color names to Color objects
    Color getColor(String colorName) {
      switch (colorName.toLowerCase()) {
        case 'orange':
          return Colors.orange;
        case 'red':
          return Colors.red;
        case 'pinkaccent':
          return Colors.pinkAccent;
        case 'blueaccent':
          return Colors.blueAccent;
        case 'greenaccent':
          return Colors.greenAccent;
        case 'lightblue':
          return Colors.lightBlue;
        case 'orangeaccent':
          return Colors.orangeAccent;
        case 'bluegrey':
          return Colors.blueGrey;
        default:
          return Colors.blue;
      }
    }

    // Helper to map string icon names to IconData
    IconData getIcon(String iconName) {
      switch (iconName) {
        case 'language':
          return Icons.language;
        case 'play_circle_filled':
          return Icons.play_circle_filled;
        case 'camera_alt':
          return Icons.camera_alt;
        case 'business_center':
          return Icons.business_center;
        case 'monetization_on':
          return Icons.monetization_on;
        case 'phone_android':
          return Icons.phone_android;
        case 'account_balance':
          return Icons.account_balance;
        default:
          return Icons.grid_view_rounded;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 48) / 4;
          return Wrap(
            spacing: 16,
            runSpacing: 24,
            children: widget.categories.map((cat) {
              return SizedBox(
                width: itemWidth,
                child: CategoryItem(
                  icon: getIcon(cat.icon),
                  label: cat.label,
                  color: getColor(cat.color),
                  onTap: () => widget.onCategorySet?.call(cat.label),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    IconData? icon,
    required String title,
    Color? iconColor,
    Color? titleColor,
    bool showViewAll = false,
    String? leadingText,
    String? viewAllLabel,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:
                    iconColor?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          if (leadingText != null) ...[
            Text(
              leadingText,
              style: TextStyle(
                color: titleColor ?? Colors.amber,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: titleColor ?? Colors.white,
            ),
          ),
          const Spacer(),
          if (showViewAll)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Text(viewAllLabel ?? 'View all',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopVideosGrid(BuildContext context, List<Course> courses) {
    if (courses.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return VideoCard(
            video: {'title': course.title, 'tag': course.tag ?? ''},
            imageUrl: course.seriesThumbnail,
            heroTag: course.id,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideoDetailsScreen(
                          course: course,
                        )),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHorizontalVideoList(BuildContext context) {
    final englishCourses = widget.courses
        .where((c) => c.category == _englishSpeakingCategory)
        .toList();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: englishCourses.length,
        itemBuilder: (context, index) {
          final course = englishCourses[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideoDetailsScreen(
                          course: course,
                        )),
              );
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: 'horizontal_${course.id}',
                  child: Image.network(
                    course.seriesThumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                          child: Icon(Icons.error, color: Colors.white54)),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
