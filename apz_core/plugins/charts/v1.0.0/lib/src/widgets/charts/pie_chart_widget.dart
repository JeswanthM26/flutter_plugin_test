import "package:apz_charts/src/models/chart_config.dart";
import "package:apz_charts/src/models/chart_data.dart";
import "package:fl_chart/fl_chart.dart" as fl;
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// A widget that displays a pie chart
class APZPieChart extends StatelessWidget {

  /// Creates an APZPieChart widget
  /// - [data] is the data to be displayed in the chart.
  /// - [config] is the configuration object that defines the appearance and
  /// behavior of the chart.
  const APZPieChart({
    required this.data,
    required this.config,
    super.key,
  });
  /// The data to display in the chart
  final APZPieData data;

  /// The configuration for the chart
  final PieChartConfig config;

  @override
  Widget build(final BuildContext context) => Padding(
      padding: config.padding,
      child: Column(
        children: <Widget>[
          if (data.title != null)
            Text(
              data.title!,
              style: data.titleStyle ?? Theme.of(context).textTheme.titleLarge,
            ),
          Expanded(
            child: fl.PieChart(
              fl.PieChartData(
                centerSpaceRadius: config.centerSpaceRadius,
                sectionsSpace: config.sectionSpacing,
                startDegreeOffset: config.startDegreeOffset,
                sections: _createSections(),
              ),
            ),
          ),
          if (config.showLegend)
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: data.sections.map((final APZPieSection section) => 
                _LegendItem(
                  label: section.label,
                  color: section.color ?? Colors.blue,
                )).toList(),
            ),
        ],
      ),
    );

  List<fl.PieChartSectionData> _createSections() => 
    data.sections.asMap()
    .entries.map((final MapEntry<int, APZPieSection> entry) {
      final APZPieSection section = entry.value;

      return fl.PieChartSectionData(
        value: section.value,
        title: config.showValues ? "${section.value.toStringAsFixed(1)}%" : "",
        color: section.color ??Colors.blue,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty<APZPieData>("data", data))
    ..add(DiagnosticsProperty<PieChartConfig>("config", config));
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.color,
  });
  final String label;
  final Color color;

  @override
  Widget build(final BuildContext context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(StringProperty("label", label))
    ..add(ColorProperty("color", color));
  }
}
