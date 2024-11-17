import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Search',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _MovieSearchAppState createState() => _MovieSearchAppState();
}

class _MovieSearchAppState extends State<HomeScreen> {

  final TextEditingController _controller = TextEditingController();
  List<Movie> _movies = [];
  final String apiKey = 'a25e9c95';
  final List<String> randomMovieTitles = [
    "Jurassic World",
    "Rampage",
    "House of the dead",
    "The Dark Knight",
    "Inception",
    "Interstellar",
    "The Matrix",
    "Avengers: Endgame",
    "Forrest Gump",
    "The Shawshank Redemption",
    "The Godfather",
    "Titanic",
    "Jurassic Park",
    "Gladiator",
    "Pulp Fiction",
    "The Lion King",
    "The Avengers",
    "Star Wars",
    "Schindler's List",
    "The Prestige",
    "The Departed",
    "Fight Club",
    "The Godfather Part II",
  ];
  bool _isLoading = false;

  @override
  void initState() {
    fetchMovies("");
    super.initState();
  }

  // Fetch movie details from OMDb API
  Future<void> fetchMovies(String movieName) async {
    if (movieName.isEmpty) {
     fetchRandomMovies();
      return;
    }
    setState(() {
      _isLoading = true;
    });



    final String url = 'http://www.omdbapi.com/?t=${Uri.encodeComponent(movieName)}&apikey=$apiKey';
    print(url);
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("response: " + response.body);
        if (data['Response'] == 'True') {
          Map<String, dynamic> data = jsonDecode(response.body);
          var movie = Movie(title: data["Title"],
              genre: data["Genre"],
              poster: data["Poster"],
              imdbRating: data["imdbRating"]);

          setState(() {
            _movies.clear();
            _movies.add(movie);
          });
        } else {
          setState(() {
            _movies = [];
          });
        }
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (error) {
      print('Error fetching movies: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> fetchRandomMovies() async {
    _movies.clear();
    var random = Random();

    // Fetch details for 10 random movies
    for (int i = 0; i < 10; i++) {
      String randomTitle = randomMovieTitles[random.nextInt(randomMovieTitles.length)];
      final url = Uri.parse('https://www.omdbapi.com/?t=${Uri.encodeComponent(randomTitle)}&apikey=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var movie = Movie(title: data["Title"],
            genre: data["Genre"],
            poster: data["Poster"],
            imdbRating: data["imdbRating"]);

        if (data['Response'] == 'True') {
          setState(() {
            _movies.add(movie);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Color(0xFFF0F0F0),
        title: Text('Movie Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter movie name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                fetchMovies(_controller.text);
              },
              child: Text('Search'),
            ),
            SizedBox(height: 10),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return MovieCard(
                    title: movie.title,
                    genres: movie.genre,
                    rating: movie.imdbRating,
                    imageUrl: movie.poster,
                  );
                },

              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MovieCard extends StatelessWidget {
  final String title;
  final String genres;
  final String rating;
  final String imageUrl;

  MovieCard({
    required this.title,
    required this.genres,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 20.0, top: 16.0, bottom: 16.0),
                // padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                child: Row(
                  children: [
                    const SizedBox(width: 140), // Space reserved for the image
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                                fontFamily: "Montserrat"
                            ),
                          ),
                          Text(
                            genres,
                            style: TextStyle(
                              fontSize: 8.0,
                              fontFamily: "Montserrat",
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            decoration: BoxDecoration(
                              color: checkColor(rating),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 1.0),
                            margin: EdgeInsets.only(top: 5.0, bottom: 20.0),
                            child: Text(
                              '${rating.toString()} IMDB',
                              style: const TextStyle(
                                fontSize: 10.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 16.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                height: 170.0,
                width: 140.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color checkColor(String rating) {
    print(rating);
    double rat = double.parse(rating);

    if(rat >= 7.5){
      return Color(0xFF5EC570);
    } else if(rat >= 5.0 && rat < 7.5){
      return Color(0xFF1C7EEB);
    } else{
      return Color(0xFFED2939);
    }
  }
}
