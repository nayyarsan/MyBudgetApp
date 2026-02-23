import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import 'goals_providers.dart';
import 'add_goal_screen.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_goals',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddGoalScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: goals.length,
            itemBuilder: (context, i) => _GoalCard(goal: goals[i]),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No goals yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + Add Goal to set a savings target\non any budget category.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalProgress goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = goal.progressPercent;
    final isComplete = goal.isComplete;
    final progressColor = isComplete
        ? Colors.green
        : percent >= 0.75
            ? colorScheme.primary
            : percent >= 0.4
                ? Colors.orange
                : colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (isComplete)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20)
                else
                  Text(
                    '${(percent * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            LinearProgressIndicator(
              value: percent,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 10),

            // Amounts row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.format(goal.totalAssignedCents),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'of ${CurrencyFormatter.format(goal.goalCents)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Projected date or "Goal reached!"
            if (isComplete)
              Row(
                children: [
                  const Icon(Icons.celebration, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Goal reached!',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.green),
                  ),
                ],
              )
            else ...[
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 12, color: Colors.grey.shade500,),
                  const SizedBox(width: 4),
                  Text(
                    _projectedLabel(goal),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _projectedLabel(GoalProgress goal) {
    final pd = goal.projectedDate;
    if (pd.year >= 9999) return 'No contributions yet — set a monthly amount';
    return 'Projected: ${DateFormat.yMMMM().format(pd)}';
  }
}
