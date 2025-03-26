class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json["id"] ?? 0,
      title: json["title"] ?? 'No Title',
      overview: json["overview"] ?? 'No overview available',
      posterPath: json["poster_path"] ?? '',
      backdropPath: json["backdrop_path"] ?? '',
      releaseDate: json["release_date"] ?? 'Unknown',
      voteAverage: (json["vote_average"] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "overview": overview,
      "poster_path": posterPath,
      "backdrop_path": backdropPath,
      "release_date": releaseDate,
      "vote_average": voteAverage,
    };
  }
}
