import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../stats_providers.dart';
import '../../../../core/themes/theme_provider.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(currentLang, 'personal_stats'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            tooltip: AppLocalizations.get(currentLang, 'theme_toggle'),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          final statusCount = stats['statusCount'] as Map<String, int>;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard(AppLocalizations.get(currentLang, 'total_anime'), "${stats['totalAnime']}", Colors.blue)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(AppLocalizations.get(currentLang, 'total_anime').replaceAll('Tổng Anime', 'Số tập').replaceAll('Total Anime', 'Episodes').replaceAll('アニメの総数', 'エピソード'), "${stats['totalEpisodes']}", Colors.orange)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatCard(AppLocalizations.get(currentLang, 'avg_score'), (stats['avgScore'] as double).toStringAsFixed(1), Colors.purple),
                
                const SizedBox(height: 32),
                Text(AppLocalizations.get(currentLang, 'status_distribution'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        _buildPieSection(statusCount['watching'] ?? 0, Colors.blue, AppLocalizations.get(currentLang, 'status_watching')),
                        _buildPieSection(statusCount['completed'] ?? 0, Colors.green, AppLocalizations.get(currentLang, 'status_completed')),
                        _buildPieSection(statusCount['following'] ?? 0, Colors.orange, AppLocalizations.get(currentLang, 'status_plan')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  children: [
                    _buildLegendItem(AppLocalizations.get(currentLang, 'status_watching'), Colors.blue),
                    _buildLegendItem(AppLocalizations.get(currentLang, 'status_completed'), Colors.green),
                    _buildLegendItem(AppLocalizations.get(currentLang, 'status_plan'), Colors.orange),
                  ],
                ),
                const SizedBox(height: 32),
                const SizedBox(height: 16),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${AppLocalizations.get(currentLang, 'error_occurred')} $e')),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withValues(alpha: 0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieSection(int value, Color color, String title) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: value > 0 ? '$value' : '',
      radius: 60,
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
