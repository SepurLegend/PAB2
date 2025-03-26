import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'b0185e88e300411f9bd671b8f3618bd2';

  Future<List<Map<String, dynamic>>> _fetchData(String endpoint) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/$endpoint?api_key=$_apiKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllMovies() =>
      _fetchData('movie/now_playing');
  Future<List<Map<String, dynamic>>> getTrendingMovies() =>
      _fetchData('trending/movie/week');
  Future<List<Map<String, dynamic>>> getPopularMovies() =>
      _fetchData('movie/popular');

  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
