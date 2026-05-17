import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/anime_model.dart';
import '../../home/presentation/home_providers.dart';

final animeDetailProvider = FutureProvider.family<AnimeModel, int>((ref, id) async {
  final apiService = ref.read(jikanApiServiceProvider);
  return apiService.getAnimeDetails(id);
});
