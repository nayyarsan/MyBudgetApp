import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

/// A single budget category row showing budgeted / spent / available columns.
class CategoryRow extends StatelessWidget {
  final String name;
  final int assignedCents;
  final int spentCents;
  final int availableCents;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CategoryRow({
    super.key,
    required this.name,
    required this.assignedCents,
    required this.spentCents,
    required this.availableCents,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isOverspent = availableCents < 0;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                CurrencyFormatter.format(assignedCents),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                CurrencyFormatter.format(spentCents),
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                CurrencyFormatter.format(availableCents),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isOverspent ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
