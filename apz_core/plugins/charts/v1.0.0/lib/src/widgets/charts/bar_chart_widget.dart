import "package:apz_charts/src/models/chart_config.dart";
import "package:apz_charts/src/models/chart_data.dart";
import "package:fl_chart/fl_chart.dart" as fl;
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// A widget that displays a bar chart
class APZBarChart extends StatelessWidget {

  /// Creates an APZBarChart widget
  /// - [data] is the data to be displayed in the chart.
  /// - [config] is the configuration object that defines the appearance and 
  /// behavior of the chart
  const APZBarChart({
    required this.data,
    required this.config,
    super.key,
  });
  /// The data to display in the chart
  final APZBarData data;

  /// The configuration for the chart
  final BarChartConfig config;

  @override
  Widget build(final BuildContext context) {
    const double reservedeSize = 44;

    return Padding(
      padding: config.padding,
      child: Column(
        children: <Widget>[
          if (data.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                data.title!,
                style: data.titleStyle ?? 
                  Theme.of(context).textTheme.titleLarge,
              ),
            ),
          Expanded(
            child: fl.BarChart(
              fl.BarChartData(
                gridData: fl.FlGridData(
                  show: config.showGridLines,
                  drawVerticalLine: config.showGridLines,
                  getDrawingHorizontalLine: (final double value) => fl.FlLine(
                    color: Colors.grey.withValues(alpha: 0.3),
                    strokeWidth: 0.5,
                  ),
                  getDrawingVerticalLine: (final double value) => fl.FlLine(
                    color: Colors.grey.withValues(alpha: 0.3),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: fl.FlTitlesData(
                  /// Future, you can add more titles here
                  /// Also can align Y axis on left or right side of the chart
                  /// Or show both the Y Axes left and Right
                  rightTitles: const fl.AxisTitles(
                    sideTitles: fl.SideTitles(reservedSize: reservedeSize),
                  ),
                  topTitles: const fl.AxisTitles(
                    sideTitles: fl.SideTitles(reservedSize: reservedeSize),
                  ),
                  bottomTitles: fl.AxisTitles(
                    sideTitles: fl.SideTitles(
                      showTitles: true,
                      getTitlesWidget: 
                        (final double value, final fl.TitleMeta meta) {
                          if (value < 0 || value >= data.groups.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data.groups[value.toInt()].groupLabel,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                    ),
                  ),
                ),
                borderData: fl.FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                backgroundColor: config.backgroundColor,
                minY: config.minY ?? 0,
                maxY: config.maxY,
                barGroups: _createBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  

  List<fl.BarChartGroupData> _createBarGroups() => 
    data.groups.asMap().entries.map((final MapEntry<int, APZBarGroup> entry) {
      final int index = entry.key;
      final APZBarGroup group = entry.value;

      return fl.BarChartGroupData(
        x: index,
        barRods: group.items
          .asMap().entries.map((final MapEntry<int, APZBarItem> itemEntry) {
            final APZBarItem item = itemEntry.value;
            return fl.BarChartRodData(
              toY: item.value,
              color: item.color ?? Colors.blue,
              width: item.width ?? 10,
            );
          }).toList(),
      );
    }).toList();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty<APZBarData>("data", data))
    ..add(DiagnosticsProperty<BarChartConfig>("config", config));
  }
}
