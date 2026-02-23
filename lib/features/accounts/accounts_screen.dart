import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import 'account_providers.dart';
import 'add_account_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final netWorthAsync = ref.watch(netWorthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: Column(
        children: [
          // Net worth summary card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 32, color: Colors.teal),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Net Worth',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      netWorthAsync.when(
                        data: (cents) => Text(
                          CurrencyFormatter.format(cents),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cents < 0 ? Colors.red : null,
                              ),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('—'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: accountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No accounts yet.\nTap + to add your first account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final a = accounts[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: Icon(
                          _accountIcon(a.type),
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                      title: Text(a.name),
                      subtitle: Text(
                        '${a.institution ?? a.type}'
                        '${a.type == 'credit' ? ' (credit)' : ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        CurrencyFormatter.format(a.balanceCents),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: a.balanceCents < 0 ? Colors.red : null,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_accounts',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AddAccountScreen(),
          ),
        ),
        tooltip: 'Add account',
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _accountIcon(String type) {
    switch (type) {
      case 'checking':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      case 'credit':
        return Icons.credit_card;
      case 'cash':
        return Icons.payments;
      default:
        return Icons.attach_money;
    }
  }
}
