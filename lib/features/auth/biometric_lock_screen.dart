import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'auth_providers.dart';

/// Wraps the app and shows a lock screen when biometric is enabled and
/// the session is not yet authenticated.
class BiometricLockScreen extends ConsumerWidget {
  final Widget child;

  const BiometricLockScreen({super.key, required this.child});

  Future<void> _authenticate(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(localAuthProvider);
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheck && !isDeviceSupported) {
        // Device has no biometric — unlock automatically
        ref.read(isUnlockedProvider.notifier).state = true;
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access MyYNAB',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        ref.read(isUnlockedProvider.notifier).state = true;
      }
    } catch (_) {
      // Authentication failed — stay locked
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricAsync = ref.watch(biometricEnabledProvider);
    final isUnlocked = ref.watch(isUnlockedProvider);

    return biometricAsync.when(
      data: (enabled) {
        if (!enabled || isUnlocked) return child;
        return _LockScreen(onUnlock: () => _authenticate(context, ref));
      },
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => child, // on error, show app normally
    );
  }
}

class _LockScreen extends StatelessWidget {
  final VoidCallback onUnlock;

  const _LockScreen({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B6CA8)),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 72, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'MyYNAB',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your budget is locked.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onUnlock,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
