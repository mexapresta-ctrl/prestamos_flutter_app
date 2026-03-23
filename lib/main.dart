import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/update/update_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/update_provider.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    // Wrap the app with ProviderScope for Riverpod
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  Timer? _updateTimer;
  bool _showingUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Poll every 5 minutes
    _updateTimer = Timer.periodic(const Duration(minutes: 5), (_) => _checkForUpdates());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForUpdates();
    }
  }

  Future<void> _checkForUpdates() async {
    if (_showingUpdate) return;
    try {
      // Allow Splash Screen time to run its own lifecycle first if just started
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return;

      ref.invalidate(updateProvider);
      final updateInfo = await ref.read(updateProvider.future);
      
      if (updateInfo.isUpdateRequired && !_showingUpdate) {
        _showingUpdate = true;
        if (globalNavigatorKey.currentState != null) {
          globalNavigatorKey.currentState!.pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const UpdateScreen(),
              transitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            ),
            (route) => false, // Clears everything underneath
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      title: 'Prestamos App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3447E8)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F1F9),
      ),
      home: const SplashScreen(),
    );
  }
}
