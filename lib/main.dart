import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';
import 'core/providers/update_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/update/update_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();

  runApp(
    // Wrap the app with ProviderScope for Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prestamos App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3447E8)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F1F9),
      ),
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateProvider);

    return updateState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF3447E8))),
      ),
      error: (err, stack) => const LoginScreen(),
      data: (info) {
        if (info.isUpdateRequired && info.updateUrl != null) {
          return UpdateScreen(appUrl: info.updateUrl!);
        }
        return const LoginScreen();
      },
    );
  }
}
