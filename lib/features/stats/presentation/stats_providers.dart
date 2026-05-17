import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../mylist/presentation/mylist_providers.dart';

final statsProvider = Provider((ref) {
  final watchlistAsync = ref.watch(watchlistProvider);
  
  return watchlistAsync.whenData((list) {
    int totalAnime = list.length;
    int totalEpisodes = list.fold(0, (sum, item) => sum + item.episodesWatched);
    
    final scoredItems = list.where((item) => item.scoreUser != null && item.scoreUser! > 0);
    double avgScore = scoredItems.isEmpty 
        ? 0.0 
        : scoredItems.fold(0.0, (sum, item) => sum + item.scoreUser!) / scoredItems.length;

    Map<String, int> statusCount = {
      'watching': 0, 'completed': 0, 'following': 0
    };
    for (var item in list) {
      if (statusCount.containsKey(item.status)) {
        statusCount[item.status] = statusCount[item.status]! + 1;
      }
    }

    return {
      'totalAnime': totalAnime,
      'totalEpisodes': totalEpisodes,
      'avgScore': avgScore,
      'statusCount': statusCount,
    };
  });
});
