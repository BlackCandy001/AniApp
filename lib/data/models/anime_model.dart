class AnimeModel {
  final int malId;
  final String title;
  final String? titleEnglish;
  final String? titleJapanese;
  final String imageUrl;
  final String? synopsis;
  final String status;
  final int? episodes;
  final double? score;
  final String? year;
  final List<String> genres;
  // V4 fields
  final String? trailerYoutubeId;
  final String? duration;
  final String? rating;
  final String? source;
  final String? background;
  final String? airedString;
  final String? broadcastString;

  AnimeModel({
    required this.malId,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    required this.imageUrl,
    this.synopsis,
    required this.status,
    this.episodes,
    this.score,
    this.year,
    required this.genres,
    this.trailerYoutubeId,
    this.duration,
    this.rating,
    this.source,
    this.background,
    this.airedString,
    this.broadcastString,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    return AnimeModel(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      titleEnglish: json['title_english'],
      titleJapanese: json['title_japanese'],
      imageUrl: json['images']?['jpg']?['large_image_url'] ?? '',
      synopsis: json['synopsis'],
      status: json['status'] ?? 'Unknown',
      episodes: json['episodes'],
      score: (json['score'] as num?)?.toDouble(),
      year: json['year']?.toString(),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e['name'] as String)
              .toList() ??
          [],
      trailerYoutubeId: json['trailer']?['youtube_id'] ?? _extractYoutubeId(json['trailer']?['embed_url']),
      duration: json['duration'],
      rating: json['rating'],
      source: json['source'],
      background: json['background'],
      airedString: json['aired']?['string'],
      broadcastString: json['broadcast']?['string'],
    );
  }

  static String? _extractYoutubeId(String? embedUrl) {
    if (embedUrl == null || embedUrl.isEmpty) return null;
    final uri = Uri.tryParse(embedUrl);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments.contains('embed')) {
        return uri.pathSegments.last;
      }
    }
    return null;
  }
}
