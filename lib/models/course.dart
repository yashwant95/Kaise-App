class Episode {
  final String id;
  final String title;
  final String duration;
  final String date;
  final String videoUrl;
  final String thumbnailUrl;
  final bool isNew;

  Episode({
    required this.id,
    required this.title,
    required this.duration,
    required this.date,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.isNew = false,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      date: json['date'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      isNew: json['isNew'] ?? false,
    );
  }
}

class Course {
  final String id;
  final String title;
  final String category;
  final String description;
  final String seriesThumbnail;
  final String tag;
  final List<Episode> episodes;
  final double rating;
  final int reviewsCount;
  final bool isFree;

  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.seriesThumbnail,
    required this.tag,
    required this.episodes,
    required this.rating,
    required this.reviewsCount,
    this.isFree = true,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var episodesList = json['episodes'] as List;
    List<Episode> episodeObjects =
        episodesList.map((e) => Episode.fromJson(e)).toList();

    return Course(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      seriesThumbnail: json['seriesThumbnail'] ?? '',
      tag: json['tag'] ?? 'New',
      episodes: episodeObjects,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      isFree: json['isFree'] ?? true,
    );
  }
}
