class Episode {
  final String id;
  final String title;
  final String date;
  final String videoUrl;
  final String thumbnailUrl;
  final bool isNew;

  Episode({
    required this.id,
    required this.title,
    required this.date,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.isNew = false,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
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
  final String description;
  final String seriesThumbnail;
  final List<Episode> episodes;
  final int reviewsCount;
  final int viewCount;
  final bool isFree;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.seriesThumbnail,
    required this.episodes,
    required this.reviewsCount,
    this.viewCount = 0,
    this.isFree = true,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var episodesList = json['episodes'] as List;
    List<Episode> episodeObjects =
        episodesList.map((e) => Episode.fromJson(e)).toList();

    return Course(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      seriesThumbnail: json['seriesThumbnail'] ?? '',
      episodes: episodeObjects,
      reviewsCount: json['reviewsCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      isFree: json['isFree'] ?? true,
    );
  }
}
