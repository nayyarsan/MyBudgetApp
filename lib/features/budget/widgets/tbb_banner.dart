import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

/// "To Be Budgeted" banner shown at the top of the budget screen.
/// Green when positive (money left to assign), red when negative (over-assigned).
class ToBeBudgetedBanner extends StatelessWidget {
  final int tbbCents;

  const ToBeBudgetedBanner({super.key, required this.tbbCents});

  @override
  Widget build(BuildContext context) {
    final isNegative = tbbCents < 0;
    final color = isNegative
        ? Colors.red.shade700
        : Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: color,
      child: Column(
        children: [
          Text(
            'To Be Budgeted',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(tbbCents),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (isNegative)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Over-assigned! Move money from other categories.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
