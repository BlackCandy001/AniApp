import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../mylist_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';

class MyListScreen extends ConsumerStatefulWidget {
  const MyListScreen({super.key});

  @override
  ConsumerState<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends ConsumerState<MyListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCheckingUpdates = false;

  final statusValues = ['all', 'watching', 'completed', 'following'];

  Future<void> _checkUpdates(String currentLang) async {
    if (_isCheckingUpdates) return;
    setState(() => _isCheckingUpdates = true);

    final count = await TrackingService().checkForUpdates();
    
    if (mounted) {
      setState(() => _isCheckingUpdates = false);
      // Tải lại danh sách sau khi đã cập nhật số tập trong DB
      ref.read(watchlistProvider.notifier).loadWatchlist();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: count > 0
              ? Text(AppLocalizations.get(currentLang, 'updates_found').replaceFirst('{count}', count.toString()))
              : Text(AppLocalizations.get(currentLang, 'no_updates')),
          backgroundColor: count > 0 ? Colors.green.shade600 : null,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusValues.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final watchlistAsync = ref.watch(watchlistProvider);
    final currentLang = ref.watch(languageProvider);

    final tabs = [
      AppLocalizations.get(currentLang, 'filter_all'),
      AppLocalizations.get(currentLang, 'status_watching'),
      AppLocalizations.get(currentLang, 'status_completed'),
      AppLocalizations.get(currentLang, 'status_plan'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(currentLang, 'my_list_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          _isCheckingUpdates
              ? const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.notifications_active_outlined),
                  tooltip: AppLocalizations.get(currentLang, 'check_updates'),
                  onPressed: () => _checkUpdates(currentLang),
                ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: watchlistAsync.when(
        data: (list) {
          return TabBarView(
            controller: _tabController,
            children: statusValues.map((status) {
              final filtered = status == 'all'
                  ? List.from(list)
                  : list.where((item) => item.status == status).toList();
                  
              filtered.sort((a, b) => (b.scoreUser ?? 0).compareTo(a.scoreUser ?? 0));
                  
              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.get(currentLang, 'empty_list'), style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                );
              }
              
              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Dismissible(
                    key: Key(item.malId.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red.shade400,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      ref.read(watchlistProvider.notifier).delete(item.malId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${AppLocalizations.get(currentLang, 'deleted')} ${item.title}')),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Hero(
                          tag: 'anime-poster-mylist-${item.malId}',
                          child: CachedNetworkImage(
                            imageUrl: item.posterUrl,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text("${AppLocalizations.get(currentLang, 'progress')}: ${item.episodesWatched}/${item.episodesTotal ?? '?'}  •  ${AppLocalizations.get(currentLang, 'score')}: ${item.scoreUser ?? '-'} \u2B50"),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        context.push(Uri(
                          path: '/detail/${item.malId}',
                          queryParameters: {
                            'imageUrl': item.posterUrl,
                            'heroTag': 'anime-poster-mylist-${item.malId}'
                          },
                        ).toString());
                      },
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${AppLocalizations.get(currentLang, 'load_error')}: $err')),
      ),
    );
  }
}
