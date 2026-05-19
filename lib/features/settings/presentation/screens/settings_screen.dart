import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/theme_provider.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../mylist/presentation/mylist_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    
    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(currentLang, 'settings'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Giao diện
          _SectionTitle(title: AppLocalizations.get(currentLang, 'appearance_language')),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(AppLocalizations.get(currentLang, 'dark_mode')),
                  subtitle: Text(AppLocalizations.get(currentLang, 'dark_mode_desc')),
                  value: isDark,
                  onChanged: (val) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  secondary: const Icon(Icons.brightness_6),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(AppLocalizations.get(currentLang, 'language')),
                  subtitle: Text(AppLocalizations.get(currentLang, 'language_desc')),
                  trailing: DropdownButton<String>(
                    value: currentLang,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ja', child: Text('日本語')),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await ref.read(languageProvider.notifier).setLanguage(val);
                        if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text(AppLocalizations.get(val, 'language_changed'))),
                           );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quản lý dữ liệu
          _SectionTitle(title: AppLocalizations.get(currentLang, 'data_management')),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(AppLocalizations.get(currentLang, 'export_data')),
                  subtitle: Text(AppLocalizations.get(currentLang, 'export_data_desc')),
                  onTap: () async {
                    try {
                      final jsonStr = await ref.read(watchlistProvider.notifier).exportData();
                      await Clipboard.setData(ClipboardData(text: jsonStr));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.get(currentLang, 'copied_clipboard'))),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${AppLocalizations.get(currentLang, 'error_occurred')} $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(AppLocalizations.get(currentLang, 'delete_all'), style: const TextStyle(color: Colors.red)),
                  subtitle: Text(AppLocalizations.get(currentLang, 'delete_all_desc')),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(AppLocalizations.get(currentLang, 'warning')),
                        content: Text(AppLocalizations.get(currentLang, 'delete_confirm')),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.get(currentLang, 'cancel'))),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true), 
                            child: Text(AppLocalizations.get(currentLang, 'delete'), style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      await ref.read(watchlistProvider.notifier).deleteAll();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.get(currentLang, 'deleted_all'))));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
