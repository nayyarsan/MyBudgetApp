import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../analytics_providers.dart';

class SpendingByCategoryChart extends StatefulWidget {
  final List<CategorySpending> data;

  const SpendingByCategoryChart({super.key, required this.data});

  @override
  State<SpendingByCategoryChart> createState() =>
      _SpendingByCategoryChartState();
}

class _SpendingByCategoryChartState
    extends State<SpendingByCategoryChart> {
  int _touchedIndex = -1;

  static const _colors = [
    Color(0xFF1B6CA8),
    Color(0xFF2DC9A4),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF845EC2),
    Color(0xFFFF9671),
    Color(0xFF00C9A7),
    Color(0xFFF9C74F),
    Color(0xFF90BE6D),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No spending data for this month.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final total =
        widget.data.fold<int>(0, (s, c) => s + c.spentCents);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    _touchedIndex = event.isInterestedForInteractions
                        ? (response?.touchedSection?.touchedSectionIndex ??
                            -1)
                        : -1;
                  });
                },
              ),
              sections: widget.data.asMap().entries.map((e) {
                final isTouched = e.key == _touchedIndex;
                final pct = e.value.spentCents / total * 100;
                return PieChartSectionData(
                  color: _colors[e.key % _colors.length],
                  value: e.value.spentCents.toDouble(),
                  title: isTouched
                      ? CurrencyFormatter.format(e.value.spentCents)
                      : '${pct.toStringAsFixed(0)}%',
                  radius: isTouched ? 72 : 60,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 44,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        ...widget.data.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _colors[e.key % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.value.categoryName)),
                    Text(
                      CurrencyFormatter.format(e.value.spentCents),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
