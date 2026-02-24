import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../../../core/utils/currency_formatter.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final String? accountName;
  final String? toAccountName;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
    this.onTap,
    this.accountName,
    this.toAccountName,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.amountCents < 0;
    final isIncome = transaction.amountCents > 0;

    return Dismissible(
      key: Key('tx-${transaction.id}'),
      background: Container(
        color: Colors.red.shade700,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete transaction?'),
            content:
                Text('Delete "${transaction.payee}"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isExpense
              ? Colors.red.shade50
              : isIncome
                  ? Colors.green.shade50
                  : Colors.blue.shade50,
          child: Icon(
            isExpense
                ? Icons.arrow_downward
                : isIncome
                    ? Icons.arrow_upward
                    : Icons.swap_horiz,
            color: isExpense
                ? Colors.red
                : isIncome
                    ? Colors.green
                    : Colors.blue,
            size: 18,
          ),
        ),
        title: Text(
          transaction.payee.isEmpty ? '(no payee)' : transaction.payee,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _subtitleText(),
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          CurrencyFormatter.format(transaction.amountCents.abs()),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isExpense
                ? Colors.red
                : isIncome
                    ? Colors.green
                    : Colors.blue,
          ),
        ),
      ),
    );
  }

  String _subtitleText() {
    final date = _dateLabel();
    final memo = (transaction.memo != null && transaction.memo!.isNotEmpty)
        ? ' · ${transaction.memo}'
        : '';
    final accountPart = toAccountName != null
        ? ' · ${accountName ?? ''} → $toAccountName'
        : accountName != null
            ? ' · $accountName'
            : '';
    return '$date$accountPart$memo';
  }

  String _dateLabel() {
    final d = transaction.date;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}
