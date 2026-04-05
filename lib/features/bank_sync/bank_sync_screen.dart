import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/providers.dart';
import '../../core/plaid/plaid_models.dart';
import 'bank_sync_providers.dart';

class BankSyncScreen extends ConsumerStatefulWidget {
  const BankSyncScreen({super.key});

  @override
  ConsumerState<BankSyncScreen> createState() => _BankSyncScreenState();
}

class _BankSyncScreenState extends ConsumerState<BankSyncScreen> {
  bool _connecting = false;

  Future<void> _connectAccount() async {
    setState(() => _connecting = true);
    final plaidService = ref.read(plaidServiceProvider);

    await plaidService.connectAccount(
      onSuccess: () async {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank account connected! Syncing transactions...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Trigger an immediate sync
        await ref.read(bankSyncProvider.notifier).sync();
        if (mounted) setState(() => _connecting = false);
      },
      onExit: (reason) {
        if (!mounted) return;
        setState(() => _connecting = false);
        if (reason != 'cancelled') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection failed: $reason'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  Future<void> _disconnect(int plaidAccountId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect bank account?'),
        content: const Text(
          'This removes the connection. Your existing transactions will not be deleted.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final db = ref.read(databaseProvider);
    final plaidService = ref.read(plaidServiceProvider);
    await plaidService.disconnect();
    await db.plaidDao.deletePlaidAccount(plaidAccountId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bank account disconnected.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bank Accounts')),
      body: FutureBuilder(
        future: db.plaidDao.getAllPlaidAccounts(),
        builder: (context, snapshot) {
          final accounts = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (accounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No bank accounts connected.\nTap below to connect Bank of America.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ...accounts.map((a) => ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: Text(a.institutionName),
                    subtitle: Text('····${a.mask}'),
                    trailing: TextButton(
                      onPressed: () => _disconnect(a.id),
                      child: const Text('Disconnect'),
                    ),
                  )),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _connecting ? null : _connectAccount,
                icon: _connecting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_connecting ? 'Connecting...' : 'Connect Bank Account'),
              ),
            ],
          );
        },
      ),
    );
  }
}
