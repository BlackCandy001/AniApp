import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../search_providers.dart';
import '../../../home/presentation/home_providers.dart';
import '../../../../data/models/anime_model.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchAnimeProvider);
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.get(currentLang, 'search_hint'),
              prefixIcon: const Icon(Icons.search, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              suffixIcon: query.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ),
        elevation: 0,
      ),
      body: query.trim().isEmpty
          ? _buildRecommendations(context, ref)
          : searchResults.when(
              data: (animes) {
                if (animes.isEmpty) {
                  return _buildEmptyState(currentLang);
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: animes.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final anime = animes[index];
                    return _buildSuggestionItem(context, anime, index);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => err.toString().contains('Cancelled') 
                ? const SizedBox() 
                : Center(child: Text('${AppLocalizations.get(currentLang, 'error_occurred')} $err')),
            ),
    );
  }

  Widget _buildSuggestionItem(BuildContext context, AnimeModel anime, int index) {
    return _HoverableSuggestionTile(anime: anime, index: index);
  }

  Widget _buildEmptyState(String currentLang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(AppLocalizations.get(currentLang, 'no_anime_found'), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, WidgetRef ref) {
    final topAnimeAsync = ref.watch(topAnimeProvider);
    final seasonalAsync = ref.watch(seasonsNowProvider);
    final upcomingAsync = ref.watch(seasonsUpcomingProvider);
    final currentLang = ref.watch(languageProvider);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildHorizontalSection('🔥 ${AppLocalizations.get(currentLang, 'trending_now')}', topAnimeAsync, currentLang),
          _buildHorizontalSection('📅 ${AppLocalizations.get(currentLang, 'seasonal')}', seasonalAsync, currentLang),
          _buildHorizontalSection('🆕 ${AppLocalizations.get(currentLang, 'recently_updated')}', upcomingAsync, currentLang),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHorizontalSection(String title, AsyncValue<List<AnimeModel>> asyncValue, String currentLang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: asyncValue.when(
            data: (animes) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: animes.length > 10 ? 10 : animes.length, // Chỉ hiện 10 bộ
                itemBuilder: (context, index) {
                  final anime = animes[index];
                  return _HoverableSearchCard(anime: anime, index: index);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text(AppLocalizations.get(currentLang, 'load_error'))),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HoverableSuggestionTile extends StatefulWidget {
  final AnimeModel anime;
  final int index;

  const _HoverableSuggestionTile({required this.anime, required this.index});

  @override
  State<_HoverableSuggestionTile> createState() => _HoverableSuggestionTileState();
}

class _HoverableSuggestionTileState extends State<_HoverableSuggestionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: _isHovered ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Hero(
              tag: 'anime-poster-search-${widget.anime.malId}-${widget.index}',
              child: CachedNetworkImage(
                imageUrl: widget.anime.imageUrl,
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 60, height: 90, color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          title: Text(
            widget.anime.title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: _isHovered ? Colors.blue : null),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                if (widget.anime.score != null) ...[
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('${widget.anime.score}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                ],
                Text(widget.anime.status, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          trailing: const Icon(Icons.play_circle_outline, color: Colors.blue),
          onTap: () {
            context.push(Uri(
              path: '/detail/${widget.anime.malId}',
              queryParameters: {
                'imageUrl': widget.anime.imageUrl,
                'heroTag': 'anime-poster-search-${widget.anime.malId}-${widget.index}'
              },
            ).toString());
          },
        ),
      ),
    );
  }
}

class _HoverableSearchCard extends StatefulWidget {
  final AnimeModel anime;
  final int index;

  const _HoverableSearchCard({required this.anime, required this.index});

  @override
  State<_HoverableSearchCard> createState() => _HoverableSearchCardState();
}

class _HoverableSearchCardState extends State<_HoverableSearchCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          context.push(Uri(
            path: '/detail/${widget.anime.malId}',
            queryParameters: {
              'imageUrl': widget.anime.imageUrl,
              'heroTag': 'search-recommend-${widget.anime.malId}-${widget.index}'
            },
          ).toString());
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 110,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Hero(
                    tag: 'search-recommend-${widget.anime.malId}-${widget.index}',
                    child: CachedNetworkImage(
                      imageUrl: widget.anime.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.anime.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w600,
                  color: _isHovered ? Colors.blue : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
