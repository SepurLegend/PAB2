import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';
import 'package:pilem/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Movie> searchResults = [];
  String query = '';
  final ApiService apiService = ApiService();
  List<int> favoriteMovieIds = [];
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadFavoriteMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorites') ?? [];
      setState(() {
        favoriteMovieIds = favorites
            .map((item) => Movie.fromJson(json.decode(item)).id)
            .toList();
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _toggleFavorite(Movie movie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = prefs.getStringList('favorites') ?? [];

      if (favoriteMovieIds.contains(movie.id)) {
        favorites.removeWhere(
            (item) => Movie.fromJson(json.decode(item)).id == movie.id);
      } else {
        favorites.add(json.encode(movie.toJson()));
      }

      await prefs.setStringList('favorites', favorites);
      setState(() {
        if (favoriteMovieIds.contains(movie.id)) {
          favoriteMovieIds.remove(movie.id);
        } else {
          favoriteMovieIds.add(movie.id);
        }
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Widget _buildSearchResultItem(Movie movie) {
    return ListTile(
      leading: movie.posterPath.isNotEmpty
          ? Image.network(
              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            )
          : const SizedBox(width: 50),
      title: Text(movie.title,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: IconButton(
        icon: Icon(
          favoriteMovieIds.contains(movie.id)
              ? Icons.favorite
              : Icons.favorite_border,
          color: favoriteMovieIds.contains(movie.id) ? Colors.red : Colors.grey,
        ),
        onPressed: () => _toggleFavorite(movie),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(movie: movie)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() => query = value.trim());
                  _searchMovies(query);
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchResults.isEmpty
              ? Center(
                  child: Text(
                      query.isEmpty ? 'Search for movies' : 'No results found'))
              : ListView.separated(
                  itemCount: searchResults.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  padding: const EdgeInsets.all(5.0),
                  itemBuilder: (context, index) =>
                      _buildSearchResultItem(searchResults[index]),
                ),
    );
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await apiService.searchMovies(query);
      setState(() {
        searchResults = response.map((json) => Movie.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        searchResults = [];
        _isLoading = false;
      });
    }
  }
}
