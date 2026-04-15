import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../theme/app_theme.dart';

class WeeklyChart extends StatelessWidget {
  final List<Habit> habits;

  const WeeklyChart({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final days = List.generate(
      7,
      (i) => DateTime.now().subtract(Duration(days: 6 - i)),
    );

    final groups = days.asMap().entries.map((entry) {
      final i = entry.key;
      final day = entry.value;
      final completed =
          habits.where((h) => h.isCompletedOn(day)).length.toDouble();
      final total = habits.length.toDouble();
      final fraction = total == 0 ? 0.0 : completed / total;

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: fraction,
            color: fraction > 0
                ? AppTheme.accent
                    .withOpacity(0.5 + (fraction * 0.5).clamp(0.0, 0.5))
                : AppTheme.border,
            width: 26,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This week',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Daily completion rate',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: 1.0,
                barGroups: groups,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 6,
                    getTooltipColor: (_) => AppTheme.bg,
                    getTooltipItem: (group, _, rod, __) {
                      final pct = (rod.toY * 100).round();
                      return BarTooltipItem(
                        '$pct%',
                        const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isToday = idx == 6;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('E').format(days[idx]),
                            style: TextStyle(
                              fontSize: 11,
                              color: isToday
                                  ? AppTheme.accent
                                  : AppTheme.textTertiary,
                              fontWeight: isToday
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
