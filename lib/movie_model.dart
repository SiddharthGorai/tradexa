class Movie {
  final String title;
  final String genre;
  final String poster;
  final String imdbRating;

  Movie({
    required this.title,
    required this.genre,
    required this.poster,
    required this.imdbRating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'],
      genre: json['Genre'],
      poster: json['Poster'],
      imdbRating: json['imdbRating'],
    );
  }
}


