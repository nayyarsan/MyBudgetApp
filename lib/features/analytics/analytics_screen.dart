import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_providers.dart';
import 'widgets/income_vs_expenses_chart.dart';
import 'widgets/spending_by_category_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Spending', icon: Icon(Icons.pie_chart)),
              Tab(text: 'Income vs Expenses', icon: Icon(Icons.bar_chart)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SpendingTab(),
            _IncomeVsExpensesTab(),
          ],
        ),
      ),
    );
  }
}

class _SpendingTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(spendingByCategoryProvider);

    return dataAsync.when(
      data: (data) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Spending by Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            SpendingByCategoryChart(data: data),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _IncomeVsExpensesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(monthlyTotalsProvider);

    return dataAsync.when(
      data: (data) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income vs Expenses (Last 6 Months)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            IncomeVsExpensesChart(data: data),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
