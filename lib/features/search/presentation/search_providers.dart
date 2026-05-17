import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/anime_model.dart';
import '../../home/presentation/home_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchAnimeProvider = FutureProvider<List<AnimeModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  
  // Validation: Yêu cầu ít nhất 2 ký tự
  if (query.trim().length < 2) {
    return [];
  }

  // Debounce logic (300ms) - Chuẩn streaming app
  var didDispose = false;
  ref.onDispose(() => didDispose = true);

  await Future.delayed(const Duration(milliseconds: 300));

  if (didDispose) {
    throw Exception('Cancelled');
  }

  final apiService = ref.read(jikanApiServiceProvider);
  return apiService.searchAnime(query);
});
