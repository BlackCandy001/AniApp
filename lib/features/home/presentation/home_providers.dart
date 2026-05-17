import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/api/jikan_api_service.dart';
import '../../../../data/models/anime_model.dart';

final jikanApiServiceProvider = Provider<JikanApiService>((ref) {
  return JikanApiService();
});

final seasonsNowProvider = FutureProvider<List<AnimeModel>>((ref) async {
  final apiService = ref.read(jikanApiServiceProvider);
  return apiService.getSeasonsNow();
});

final topAnimeProvider = FutureProvider<List<AnimeModel>>((ref) async {
  final apiService = ref.read(jikanApiServiceProvider);
  return apiService.getTopAnime();
});

final seasonsUpcomingProvider = FutureProvider<List<AnimeModel>>((ref) async {
  final apiService = ref.read(jikanApiServiceProvider);
  return apiService.getSeasonsUpcoming();
});
