import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import 'budget_history_providers.dart';

class BudgetHistoryScreen extends ConsumerWidget {
  const BudgetHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(budgetHistoryProvider);

    return historyAsync.when(
      data: (months) {
        if (months.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Budget history will appear here after your first month closes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Budget vs Actual',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _BudgetTrendChart(months: months),
            const SizedBox(height: 24),
            Text(
              'Monthly Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...months.map((m) => _MonthTile(month: m)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Something went wrong. Please try again.', style: TextStyle(color: Colors.grey))),
    );
  }
}

class _BudgetTrendChart extends StatelessWidget {
  final List<MonthBudgetHistory> months;

  const _BudgetTrendChart({required this.months});

  @override
  Widget build(BuildContext context) {
    // Show last 6 months max
    final display = months.take(6).toList().reversed.toList();
    final maxY = display
        .map((m) => m.totalAssigned > m.totalSpent
            ? m.totalAssigned
            : m.totalSpent,)
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.1,
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= display.length) {
                    return const SizedBox.shrink();
                  }
                  final m = display[idx].month;
                  return Text(
                    m.substring(5), // MM part
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) => Text(
                  '\$${(value / 100).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),),
          ),
          lineBarsData: [
            // Assigned line (blue)
            LineChartBarData(
              spots: display
                  .asMap()
                  .entries
                  .map((e) => FlSpot(
                        e.key.toDouble(),
                        e.value.totalAssigned.toDouble(),
                      ),)
                  .toList(),
              color: Colors.blue,
              barWidth: 2,
              dotData: const FlDotData(show: true),
            ),
            // Spent line (red)
            LineChartBarData(
              spots: display
                  .asMap()
                  .entries
                  .map((e) => FlSpot(
                        e.key.toDouble(),
                        e.value.totalSpent.toDouble(),
                      ),)
                  .toList(),
              color: Colors.red,
              barWidth: 2,
              dotData: const FlDotData(show: true),
            ),
          ],
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _MonthTile extends StatelessWidget {
  final MonthBudgetHistory month;

  const _MonthTile({required this.month});

  @override
  Widget build(BuildContext context) {
    final variance = month.totalVariance;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          month.month,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(
              'Budgeted: ${CurrencyFormatter.format(month.totalAssigned)}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 12),
            Text(
              'Spent: ${CurrencyFormatter.format(month.totalSpent)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${variance >= 0 ? '+' : ''}${CurrencyFormatter.format(variance)}',
              style: TextStyle(
                color: variance >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text('CATEGORY',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey,),),),
                    Expanded(
                        flex: 2,
                        child: Text('BUDGETED',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey,),),),
                    Expanded(
                        flex: 2,
                        child: Text('SPENT',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey,),),),
                    Expanded(
                        flex: 2,
                        child: Text('VARIANCE',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey,),),),
                  ],
                ),
                const Divider(height: 8),
                ...month.categories.map((cat) {
                  final v = cat.varianceCents;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3, child: Text(cat.categoryName),),
                        Expanded(
                          flex: 2,
                          child: Text(
                            CurrencyFormatter.format(cat.assignedCents),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            CurrencyFormatter.format(cat.spentCents),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${v >= 0 ? '+' : ''}${CurrencyFormatter.format(v)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: v > 0
                                  ? Colors.green
                                  : v < 0
                                      ? Colors.red
                                      : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
