import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../stats/presentation/stats_providers.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/user_model.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isInit = ref.watch(authInitProvider);
    final statsAsync = ref.watch(statsProvider);
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(currentLang, 'profile_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
            tooltip: AppLocalizations.get(currentLang, 'settings'),
          ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppLocalizations.get(currentLang, 'confirm')),
                    content: Text(AppLocalizations.get(currentLang, 'logout_confirm')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.get(currentLang, 'cancel'))),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text(AppLocalizations.get(currentLang, 'logout'), style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await ref.read(authProvider.notifier).logout();
                }
              },
              tooltip: AppLocalizations.get(currentLang, 'logout'),
            ),
        ],
      ),
      body: !isInit
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. THÔNG TIN NGƯỜI DÙNG ---
                  if (user == null)
                    _buildGuestSection(context, currentLang)
                  else
                    _buildUserSection(context, user),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // --- 2. THỐNG KÊ CÁ NHÂN ---
                  Text(AppLocalizations.get(currentLang, 'stats_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  statsAsync.when(
                    data: (stats) => _buildStatsContent(stats, currentLang),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('${AppLocalizations.get(currentLang, 'stats_error')} $e')),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildGuestSection(BuildContext context, String currentLang) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          const Icon(Icons.person_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.get(currentLang, 'not_logged_in'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.get(currentLang, 'login_prompt'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/register'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: Text(AppLocalizations.get(currentLang, 'register')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: Text(AppLocalizations.get(currentLang, 'login')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ImageProvider? _getAvatarImage(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return null;
    if (avatarPath.startsWith('assets/images/avatars/ava') && avatarPath.endsWith('.jpg')) {
      avatarPath = 'assets/images/avatars/avatar.jpg';
    }
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    } else if (avatarPath.startsWith('assets/')) {
      return AssetImage(avatarPath);
    } else {
      return FileImage(File(avatarPath));
    }
  }

  Widget _buildUserSection(BuildContext context, UserModel user) {
    final currentLang = ProviderScope.containerOf(context).read(languageProvider);
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: _getAvatarImage(user.avatarPath),
            child: (user.avatarPath == null || user.avatarPath!.isEmpty)
                ? const Icon(Icons.person, size: 50, color: Colors.blue)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.username,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => context.push('/edit-profile'),
          icon: const Icon(Icons.edit, size: 18),
          label: Text(AppLocalizations.get(currentLang, 'edit_info')),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsContent(Map<String, dynamic> stats, String currentLang) {
    final statusCount = stats['statusCount'] as Map<String, int>;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(AppLocalizations.get(currentLang, 'total_anime'), "${stats['totalAnime']}", Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(AppLocalizations.get(currentLang, 'episodes_watched'), "${stats['totalEpisodes']}", Colors.orange)),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard(AppLocalizations.get(currentLang, 'avg_score'), (stats['avgScore'] as double).toStringAsFixed(1), Colors.purple),
        
        const SizedBox(height: 32),
        Text(AppLocalizations.get(currentLang, 'profile_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
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
      ],
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
      radius: 50,
      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
