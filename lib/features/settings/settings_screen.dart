import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/services/rollover_provider.dart';
import '../auth/auth_providers.dart';
import '../auth/firebase_auth_service.dart';
import '../sync/sync_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _syncing = false;

  Future<void> _handleSync() async {
    setState(() => _syncing = true);
    final service = ref.read(syncServiceProvider);
    final success = await service.syncToFirestore();
    if (mounted) {
      setState(() => _syncing = false);
      ref.invalidate(lastSyncProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Sync complete!' : 'Sync failed — check your connection.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSignIn() async {
    final authService = ref.read(firebaseAuthServiceProvider);
    await authService.signInWithGoogle();
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your budget data stays on this device. Cloud sync will stop.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = ref.watch(isSignedInProvider);
    final userAsync = ref.watch(firebaseUserProvider);
    final biometricAsync = ref.watch(biometricEnabledProvider);
    final lastSyncAsync = ref.watch(lastSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          // --- Account section ---
          const _SectionHeader(title: 'Account'),
          userAsync.when(
            loading: () => const ListTile(title: Text('Loading...')),
            error: (_, __) => const ListTile(title: Text('Unavailable (offline mode)')),
            data: (user) {
              if (user == null || user.isAnonymous) {
                return ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Sign in with Google'),
                  subtitle: const Text('Enable cloud backup and sync'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _handleSignIn,
                );
              }
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Text(
                              (user.displayName ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    title: Text(user.displayName ?? 'Signed in'),
                    subtitle: Text(user.email ?? ''),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign out'),
                    onTap: _handleSignOut,
                  ),
                ],
              );
            },
          ),

          const Divider(),

          // --- Security section ---
          const _SectionHeader(title: 'Security'),
          biometricAsync.when(
            loading: () => const SwitchListTile(
              title: Text('Biometric lock'),
              value: false,
              onChanged: null,
            ),
            error: (_, __) => const ListTile(title: Text('Biometric unavailable')),
            data: (enabled) => SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric lock'),
              subtitle: const Text('Require fingerprint or face to open'),
              value: enabled,
              onChanged: (val) async {
                await setBiometricEnabled(val);
                if (val) {
                  // User is already in the app — mark this session as
                  // authenticated so the lock screen doesn't immediately
                  // appear. Biometric will be required on the next cold start.
                  ref.read(isUnlockedProvider.notifier).state = true;
                }
                ref.invalidate(biometricEnabledProvider);
              },
            ),
          ),

          const Divider(),

          // --- Budget section ---
          const _SectionHeader(title: 'Budget'),
          ref.watch(globalRolloverEnabledProvider).when(
            loading: () => const SwitchListTile(
              title: Text('Roll over unused budget'),
              value: false,
              onChanged: null,
            ),
            error: (_, __) => const ListTile(
              title: Text('Rollover unavailable'),
            ),
            data: (enabled) => SwitchListTile(
              secondary: const Icon(Icons.savings_outlined),
              title: const Text('Roll over unused budget'),
              subtitle: const Text(
                'Carry surplus from each category into the next month',
              ),
              value: enabled,
              onChanged: (val) => ref
                  .read(globalRolloverEnabledProvider.notifier)
                  .setEnabled(val),
            ),
          ),

          const Divider(),

          // --- Data & Sync section ---
          const _SectionHeader(title: 'Data & Sync'),
          lastSyncAsync.when(
            loading: () => const ListTile(
              leading: Icon(Icons.sync),
              title: Text('Sync to cloud'),
              subtitle: Text('Checking last sync...'),
            ),
            error: (_, __) => const ListTile(
              leading: Icon(Icons.sync),
              title: Text('Sync to cloud'),
            ),
            data: (lastSync) => ListTile(
              leading: _syncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              title: const Text('Sync to cloud'),
              subtitle: Text(
                isSignedIn
                    ? lastSync != null
                        ? 'Last synced: ${DateFormat.yMMMd().add_jm().format(lastSync)}'
                        : 'Never synced'
                    : 'Sign in to enable sync',
              ),
              trailing: isSignedIn ? const Icon(Icons.chevron_right) : null,
              onTap: isSignedIn && !_syncing ? _handleSync : null,
            ),
          ),

          const Divider(),

          // --- About section ---
          const _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Money in Sight'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
