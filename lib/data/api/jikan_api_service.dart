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

  /// Trả về số tập đã phát thực tế của anime
  /// Dùng trường pagination.items.total từ Jikan API thay vì đếm data.length
  /// để tránh bị giới hạn 25 tập/trang (phân trang mặc định của API)
  Future<int> getAiredEpisodesCount(int animeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/anime/$animeId/episodes?page=1'),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Ưu tiên đọc từ pagination.items.total — đây là tổng số tập THỰC TẾ đã phát
        final pagination = decoded['pagination'];
        if (pagination != null) {
          final items = pagination['items'];
          if (items != null && items['total'] != null) {
            return items['total'] as int;
          }
          // Fallback: dùng last_visible_page * 100 sẽ sai, nên dùng data.length trang cuối
          // Nhưng total là chính xác nhất, nên chỉ fallback xuống data nếu không có pagination
        }

        // Fallback nếu không có pagination (ít xảy ra)
        final List data = decoded['data'] ?? [];
        return data.length;
      }
    } catch (e) {
      // Bỏ qua lỗi để không làm gián đoạn quá trình check các anime khác
    }
    return 0;
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
