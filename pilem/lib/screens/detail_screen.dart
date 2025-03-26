import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteList = prefs.getStringList('favorites');
    if (favoriteList != null) {
      for (String movieJson in favoriteList) {
        Movie movie = Movie.fromJson(json.decode(movieJson));
        if (movie.id == widget.movie.id) {
          setState(() {
            isFavorite = true;
          });
          break;
        }
      }
    }
  }

  Future<void> toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteList = prefs.getStringList('favorites') ?? [];

    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      favoriteList.add(json.encode(widget.movie.toJson()));
    } else {
      favoriteList.removeWhere((movieJson) {
        Movie movie = Movie.fromJson(json.decode(movieJson));
        return movie.id == widget.movie.id;
      });
    }

    await prefs.setStringList('favorites', favoriteList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                'https://image.tmdb.org/t/p/w500${widget.movie.backdropPath}',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overview :',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      toggleFavorite();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(widget.movie.overview, textAlign: TextAlign.justify),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.blue),
                  const SizedBox(width: 10),
                  const Text(
                    'Release Date : ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.movie.releaseDate),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 10),
                  const Text(
                    'Rating : ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.movie.voteAverage.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
