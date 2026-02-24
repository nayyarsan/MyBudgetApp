import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/biometric_lock_screen.dart';
import 'features/onboarding/onboarding_providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured yet — app runs in offline-only mode
  }
  runApp(const ProviderScope(child: MoneyInSightApp()));
}

class MoneyInSightApp extends StatelessWidget {
  const MoneyInSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money in Sight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const BiometricLockScreen(child: _AppStartup()),
    );
  }
}

class _AppStartup extends ConsumerWidget {
  const _AppStartup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(onboardingCompleteProvider).when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const MainShell(),
      data: (done) => done ? const MainShell() : const OnboardingScreen(),
    );
  }
}
