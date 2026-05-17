import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../detail_providers.dart';
import '../../../../data/models/anime_model.dart';
import '../../../../data/models/watchlist_model.dart';
import '../widgets/update_watchlist_bottom_sheet.dart';
import '../../../mylist/presentation/mylist_providers.dart';
import '../../../../core/localization/translation_service.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../widgets/trailer_player_widget.dart';

class DetailScreen extends ConsumerWidget {
  final int malId;
  final String imageUrl;
  final String heroTag;

  const DetailScreen({super.key, required this.malId, required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(animeDetailProvider(malId));
    final watchlistAsync = ref.watch(watchlistProvider);
    final isInWatchlist = watchlistAsync.value?.any((item) => item.malId == malId) ?? false;
    final watchlistItem = isInWatchlist ? watchlistAsync.value!.firstWhere((item) => item.malId == malId) : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: detailAsync.when(
                data: (anime) => Text(
                  anime.title, 
                  style: const TextStyle(
                    fontSize: 16, 
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                loading: () => const Text(''),
                error: (_, _) => const Text(''),
              ),
              background: Hero(
                tag: heroTag,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[800]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: detailAsync.when(
              data: (anime) => _buildDetailContent(context, ref, anime, watchlistItem),
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text('Đã xảy ra lỗi: $err')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: detailAsync.when(
        data: (anime) => FloatingActionButton.extended(
          backgroundColor: isInWatchlist ? Colors.green : Theme.of(context).colorScheme.primary,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => UpdateWatchlistBottomSheet(anime: anime),
            );
          },
          icon: Icon(isInWatchlist ? Icons.check : Icons.bookmark_add, color: Colors.white),
          label: Text(isInWatchlist ? AppLocalizations.get(ref.watch(languageProvider), 'added_to_list') : AppLocalizations.get(ref.watch(languageProvider), 'add_to_list'), style: const TextStyle(color: Colors.white)),
        ),
        loading: () => null,
        error: (_, e) => null,
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, WidgetRef ref, AnimeModel anime, dynamic watchlistItem) {
    final translator = ref.read(translationServiceProvider);
    final currentLang = ref.watch(languageProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "${anime.score ?? 'N/A'}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              if (watchlistItem == null)
                Text(
                  "${AppLocalizations.get(currentLang, 'total_anime').replaceAll('Tổng Anime', 'Số tập')}: ${anime.episodes ?? '?'}", // Reused key logic, better:
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )
              else
                Row(
                  children: [
                    Text("${AppLocalizations.get(currentLang, 'progress')}: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: watchlistItem.episodesWatched > 0 ? () {
                        final updated = WatchlistModel(
                          id: watchlistItem.id,
                          malId: watchlistItem.malId,
                          title: watchlistItem.title,
                          titleJapanese: watchlistItem.titleJapanese,
                          posterUrl: watchlistItem.posterUrl,
                          status: watchlistItem.status,
                          episodesTotal: watchlistItem.episodesTotal,
                          episodesWatched: watchlistItem.episodesWatched - 1,
                          scoreUser: watchlistItem.scoreUser,
                          genres: watchlistItem.genres,
                          addedAt: watchlistItem.addedAt,
                          updatedAt: DateTime.now().toIso8601String(),
                        );
                        ref.read(watchlistProvider.notifier).addOrUpdate(updated);
                      } : null,
                    ),
                    Text("${watchlistItem.episodesWatched} / ${anime.episodes ?? '?'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: (anime.episodes == null || watchlistItem.episodesWatched < anime.episodes!) ? () {
                        final updated = WatchlistModel(
                          id: watchlistItem.id,
                          malId: watchlistItem.malId,
                          title: watchlistItem.title,
                          titleJapanese: watchlistItem.titleJapanese,
                          posterUrl: watchlistItem.posterUrl,
                          status: watchlistItem.status,
                          episodesTotal: watchlistItem.episodesTotal,
                          episodesWatched: watchlistItem.episodesWatched + 1,
                          scoreUser: watchlistItem.scoreUser,
                          genres: watchlistItem.genres,
                          addedAt: watchlistItem.addedAt,
                          updatedAt: DateTime.now().toIso8601String(),
                        );
                        ref.read(watchlistProvider.notifier).addOrUpdate(updated);
                      } : null,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: anime.genres.map((g) => Chip(
              label: Text(g, style: const TextStyle(fontSize: 12)),
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
          const SizedBox(height: 16),

          // --- V4: THÔNG TIN CHI TIẾT ---
          Card(
            elevation: 0,
            color: Theme.of(context).cardColor.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildInfoRow(AppLocalizations.get(currentLang, 'status'), anime.status),
                  if (anime.airedString != null) _buildInfoRow(AppLocalizations.get(currentLang, 'aired'), anime.airedString!),
                  if (anime.duration != null) _buildInfoRow(AppLocalizations.get(currentLang, 'duration'), anime.duration!),
                  if (anime.rating != null) _buildInfoRow(AppLocalizations.get(currentLang, 'rating'), anime.rating!),
                  if (anime.source != null) _buildInfoRow(AppLocalizations.get(currentLang, 'source'), anime.source!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- V4: NỘI DUNG (CÓ DỊCH) ---
          Text(
            AppLocalizations.get(currentLang, 'synopsis_title'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: translator.translate(anime.synopsis ?? 'Đang cập nhật...'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(AppLocalizations.get(currentLang, 'translating'), style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
              }
              return Text(
                snapshot.data ?? AppLocalizations.get(currentLang, 'translation_error'),
                style: const TextStyle(height: 1.5),
              );
            },
          ),
          
          const SizedBox(height: 24),
          Text(
            AppLocalizations.get(currentLang, 'trailer_title'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          if (anime.trailerYoutubeId != null && anime.trailerYoutubeId!.isNotEmpty)
            TrailerPlayerWidget(youtubeId: anime.trailerYoutubeId!)
          else
            Text(AppLocalizations.get(currentLang, 'no_trailer'), style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          
          const SizedBox(height: 24),
          Text(
            AppLocalizations.get(currentLang, 'background_title'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (anime.background != null && anime.background!.isNotEmpty)
            FutureBuilder<String>(
              future: translator.translate(anime.background!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(AppLocalizations.get(currentLang, 'translating'), style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
                }
                return Text(
                  snapshot.data ?? AppLocalizations.get(currentLang, 'translation_error'),
                  style: const TextStyle(height: 1.5),
                );
              },
            )
          else
            Text(AppLocalizations.get(currentLang, 'no_background'), style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          
          const SizedBox(height: 80), // Để tránh bị che bởi nút FAB
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
