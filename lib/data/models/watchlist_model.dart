class WatchlistModel {
  final int? id;
  final int userId;       // ID của người dùng sở hữu bản ghi này (0 = chưa đăng nhập)
  final int malId;
  final String title;
  final String? titleJapanese;
  final String posterUrl;
  final String status;
  final int? episodesTotal;
  final int episodesWatched;
  final double? scoreUser;
  final String? genres; // JSON string
  final String addedAt;
  final String updatedAt;

  WatchlistModel({
    this.id,
    this.userId = 0,
    required this.malId,
    required this.title,
    this.titleJapanese,
    required this.posterUrl,
    required this.status,
    this.episodesTotal,
    this.episodesWatched = 0,
    this.scoreUser,
    this.genres,
    required this.addedAt,
    required this.updatedAt,
  });

  factory WatchlistModel.fromMap(Map<String, dynamic> map) {
    return WatchlistModel(
      id: map['id'],
      userId: map['user_id'] ?? 0,
      malId: map['mal_id'],
      title: map['title'],
      titleJapanese: map['title_japanese'],
      posterUrl: map['poster_url'],
      status: map['status'],
      episodesTotal: map['episodes_total'],
      episodesWatched: map['episodes_watched'] ?? 0,
      scoreUser: map['score_user'],
      genres: map['genres'],
      addedAt: map['added_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'mal_id': malId,
      'title': title,
      'title_japanese': titleJapanese,
      'poster_url': posterUrl,
      'status': status,
      'episodes_total': episodesTotal,
      'episodes_watched': episodesWatched,
      'score_user': scoreUser,
      'genres': genres,
      'added_at': addedAt,
      'updated_at': updatedAt,
    };
  }
}
