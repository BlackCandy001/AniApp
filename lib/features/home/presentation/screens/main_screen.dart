import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/tracking_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/screens/edit_profile_screen.dart';
import 'home_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../mylist/presentation/screens/mylist_screen.dart';
import '../../../profile/presentation/screens/info_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isOffline = false;
  
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    MyListScreen(),
    InfoScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Tự động kiểm tra cập nhật khi mới mở app
    TrackingService().checkForUpdates();
    _loadTabPreference();
    
    if (Platform.isAndroid) {
      _checkLostAvatarData();
    }
    
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (mounted) {
        setState(() {
          _isOffline = results.contains(ConnectivityResult.none);
        });
      }
    });
    Connectivity().checkConnectivity().then((results) {
      if (mounted) {
        setState(() {
          _isOffline = results.contains(ConnectivityResult.none);
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Tự động kiểm tra cập nhật khi app quay lại hoạt động từ ngầm
      TrackingService().checkForUpdates();
    }
  }

  Future<void> _loadTabPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt('active_tab_index');
      if (savedIndex != null && savedIndex >= 0 && savedIndex < _screens.length) {
        if (mounted) {
          setState(() {
            _currentIndex = savedIndex;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveTabPreference(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_tab_index', index);
    } catch (_) {}
  }

  Future<void> _checkLostAvatarData() async {
    try {
      final picker = ImagePicker();
      final response = await picker.retrieveLostData();
      if (!response.isEmpty && response.file != null) {
        ref.read(lostAvatarProvider.notifier).state = response.file;
        if (mounted) {
          context.push('/edit-profile');
        }
      }
    } catch (e) {
      debugPrint('Lỗi retrieveLostData tại MainScreen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      body: Column(
        children: [
          if (_isOffline)
            Container(
              color: Colors.red.shade600,
              width: double.infinity,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 4, bottom: 4),
              child: Text(
                AppLocalizations.get(currentLang, 'offline_banner'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          _saveTabPreference(index);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: AppLocalizations.get(currentLang, 'nav_home')),
          NavigationDestination(icon: const Icon(Icons.search_outlined), selectedIcon: const Icon(Icons.search), label: AppLocalizations.get(currentLang, 'nav_search')),
          NavigationDestination(icon: const Icon(Icons.list_alt_outlined), selectedIcon: const Icon(Icons.list_alt), label: AppLocalizations.get(currentLang, 'nav_mylist')),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: AppLocalizations.get(currentLang, 'nav_profile')),
        ],
      ),
    );
  }
}
