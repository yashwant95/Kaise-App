import 'course.dart';
import 'category.dart';

class FrontPageCategory {
  final Category category;
  final List<Course> apps;

  FrontPageCategory({required this.category, required this.apps});

  factory FrontPageCategory.fromJson(Map<String, dynamic> json) {
    final appsJson = (json['apps'] as List?) ?? [];
    final apps = appsJson
        .map((item) => Course.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return FrontPageCategory(
      category: Category.fromJson(json),
      apps: apps,
    );
  }
}

class FrontPageData {
  final List<Course> mostViewed;
  final List<Course> newest;
  final List<Course> topPicks;
  final List<FrontPageCategory> categories;

  FrontPageData({
    required this.mostViewed,
    required this.newest,
    required this.topPicks,
    required this.categories,
  });

  factory FrontPageData.fromJson(Map<String, dynamic> json) {
    final highlights = (json['highlights'] as Map<String, dynamic>?) ?? {};
    final categoriesJson = (json['categories'] as List?) ?? [];

    List<Course> parseCourseList(String key) {
      final list = (highlights[key] as List?) ?? [];
      return list
          .map((item) => Course.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return FrontPageData(
      mostViewed: parseCourseList('mostViewed'),
      newest: parseCourseList('newest'),
      topPicks: parseCourseList('topPicks'),
      categories: categoriesJson
          .map((item) =>
              FrontPageCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
