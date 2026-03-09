import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../recurring_providers.dart';
import 'recurring_review_sheet.dart';

class RecurringDueBanner extends ConsumerWidget {
  const RecurringDueBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRecurringProvider);

    return pendingAsync.when(
      data: (pending) {
        if (pending.isEmpty) return const SizedBox.shrink();
        return MaterialBanner(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          content: Text(
            '${pending.length} recurring transaction${pending.length == 1 ? '' : 's'} due — Review',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          leading: Icon(
            Icons.repeat,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          actions: [
            TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const RecurringReviewSheet(),
              ),
              child: const Text('Review'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
