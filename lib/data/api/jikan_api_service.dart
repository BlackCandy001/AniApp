import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/anime_model.dart';

class JikanApiService {
  Future<List<AnimeModel>> getSeasonsNow({int page = 1}) async {
    return _fetchAnimeList('/seasons/now?page=$page');
  }

  Future<List<AnimeModel>> getSeasonsUpcoming({int page = 1}) async {
    return _fetchAnimeList('/seasons/upcoming?page=$page');
  }

  Future<List<AnimeModel>> getTopAnime({int page = 1}) async {
    return _fetchAnimeList('/top/anime?page=$page');
  }

  Future<List<AnimeModel>> searchAnime(String query, {int page = 1}) async {
    return _fetchAnimeList('/anime?q=$query&page=$page');
  }

  Future<List<AnimeModel>> getAnimeByGenres(String genresIds, {int page = 1}) async {
    return _fetchAnimeList('/anime?genres=$genresIds&page=$page');
  }

  Future<AnimeModel> getAnimeDetails(int id) async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/anime/$id'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return AnimeModel.fromJson(decoded['data']);
    } else {
      throw Exception('Failed to load anime details: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getGenres() async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/genres/anime'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['data'] ?? [];
    } else {
      throw Exception('Failed to load genres: ${response.statusCode}');
    }
  }

  Future<List<AnimeModel>> _fetchAnimeList(String endpoint) async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}$endpoint'));
    
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> data = decoded['data'] ?? [];
      return data.map((json) => AnimeModel.fromJson(json)).toList();
    } else if (response.statusCode == 429) {
      throw Exception('Rate Limit Exceeded. Please try again later.');
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
