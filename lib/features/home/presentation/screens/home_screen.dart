import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../home_providers.dart';
import '../../../../data/models/anime_model.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsNowAsync = ref.watch(seasonsNowProvider);
    final topAnimeAsync = ref.watch(topAnimeProvider);
    final upcomingAsync = ref.watch(seasonsUpcomingProvider);
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AniApp', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCarousel(seasonsNowAsync),
            const SizedBox(height: 24),
            _buildSectionTitle(AppLocalizations.get(currentLang, 'seasons_now')),
            _buildHorizontalList(seasonsNowAsync, 'now'),
            const SizedBox(height: 16),
            _buildSectionTitle(AppLocalizations.get(currentLang, 'top_anime')),
            _buildHorizontalList(topAnimeAsync, 'top'),
            const SizedBox(height: 16),
            _buildSectionTitle(AppLocalizations.get(currentLang, 'upcoming')),
            _buildHorizontalList(upcomingAsync, 'upcoming'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildHeroCarousel(AsyncValue<List<AnimeModel>> asyncValue) {
    return asyncValue.when(
      data: (animes) {
        if (animes.isEmpty) return const SizedBox(height: 300);
        
        final hotAnimes = animes.take(5).toList();
        
        return CarouselSlider(
          options: CarouselOptions(
            height: 450.0,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: false,
          ),
          items: hotAnimes.map((anime) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    context.push(Uri(
                      path: '/detail/${anime.malId}',
                      queryParameters: {
                        'imageUrl': anime.imageUrl,
                        'heroTag': 'hero-carousel-${anime.malId}'
                      },
                    ).toString());
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'hero-carousel-${anime.malId}',
                        child: CachedNetworkImage(
                          imageUrl: anime.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('HOT', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                if (anime.score != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${anime.score}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              anime.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: anime.genres.take(3).map((genre) => Text(
                                genre,
                                style: TextStyle(color: Colors.grey[300], fontSize: 13),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox(
        height: 450,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox(height: 450, child: Center(child: Text('Lỗi tải dữ liệu'))),
    );
  }

  /// Danh sách Anime hiển thị theo chiều ngang (phone) hoặc GridView 2 cột (tablet/landscape).
  /// Sử dụng [LayoutBuilder] để phát hiện kích thước màn hình và điều chỉnh layout.
  Widget _buildHorizontalList(AsyncValue<List<AnimeModel>> asyncValue, String prefix) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 600;

        return asyncValue.when(
          data: (animes) {
            if (isWideScreen) {
              // Tablet / Landscape: hiển thị GridView 2 cột
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: animes.length > 10 ? 10 : animes.length,
                itemBuilder: (context, index) {
                  final anime = animes[index];
                  return _AnimeCardWidget(anime: anime, prefix: prefix, index: index);
                },
              );
            } else {
              // Phone / Portrait: hiển thị ListView ngang như cũ
              return SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: animes.length,
                  itemBuilder: (context, index) {
                    final anime = animes[index];
                    return _AnimeCardWidget(anime: anime, prefix: prefix, index: index);
                  },
                ),
              );
            }
          },
          loading: () => const SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => const SizedBox(
            height: 100,
            child: Center(child: Text('Lỗi tải dữ liệu')),
          ),
        );
      },
    );
  }
}

class _AnimeCardWidget extends StatefulWidget {
  final AnimeModel anime;
  final String prefix;
  final int index;

  const _AnimeCardWidget({required this.anime, required this.prefix, required this.index});

  @override
  State<_AnimeCardWidget> createState() => _AnimeCardWidgetState();
}

class _AnimeCardWidgetState extends State<_AnimeCardWidget> {
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
              'heroTag': 'anime-poster-${widget.prefix}-${widget.anime.malId}-${widget.index}'
            },
          ).toString());
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 140, // Increased width
          margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8), // More spacing
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'anime-poster-${widget.prefix}-${widget.anime.malId}-${widget.index}',
                        child: CachedNetworkImage(
                          imageUrl: widget.anime.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[800],
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      // Gradient for hover effect and score visibility
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isHovered ? 1.0 : 0.6,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      if (widget.anime.score != null)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text('${widget.anime.score}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.anime.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14, 
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
