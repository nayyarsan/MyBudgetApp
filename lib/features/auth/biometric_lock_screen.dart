import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'auth_providers.dart';

/// Wraps the app and shows a lock screen when biometric is enabled and
/// the session is not yet authenticated.
class BiometricLockScreen extends ConsumerWidget {
  final Widget child;

  const BiometricLockScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricAsync = ref.watch(biometricEnabledProvider);
    final isUnlocked = ref.watch(isUnlockedProvider);

    return biometricAsync.when(
      data: (enabled) {
        if (!enabled || isUnlocked) return child;
        return const _LockScreen();
      },
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => child,
    );
  }
}

class _LockScreen extends ConsumerStatefulWidget {
  const _LockScreen();

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen> {
  bool _authenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-trigger the auth prompt as soon as the lock screen appears.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _errorMessage = null;
    });

    final auth = ref.read(localAuthProvider);
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheck && !isDeviceSupported) {
        // Device has no biometric hardware — unlock automatically.
        ref.read(isUnlockedProvider.notifier).state = true;
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access MyYNAB',
        options: const AuthenticationOptions(
          biometricOnly: false, // also accepts device PIN/pattern
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        ref.read(isUnlockedProvider.notifier).state = true;
      } else {
        if (mounted) {
          setState(() {
            _authenticating = false;
            _errorMessage = 'Authentication failed. Try again.';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _authenticating = false;
          _errorMessage = 'Could not authenticate. Try again.';
        });
      }
    }
  }

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
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _authenticating ? null : _authenticate,
                icon: _authenticating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.fingerprint),
                label: Text(_authenticating ? 'Authenticating…' : 'Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
