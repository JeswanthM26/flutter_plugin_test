import "package:apz_charts/src/models/chart_config.dart";
import "package:apz_charts/src/models/chart_data.dart";
import "package:fl_chart/fl_chart.dart" as fl;
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// A widget that displays a radar chart
class APZRadarChart extends StatelessWidget {

  /// Creates an APZRadarChart widget
  /// - [data] is the data to be displayed in the chart.
  /// - [config] is the configuration object that defines the appearance and
  /// behavior of the chart.
  const APZRadarChart({
    required this.data,
    required this.config,
    super.key,
  });
  /// The data to display in the chart
  final APZRadarData data;

  /// The configuration for the chart
  final RadarChartConfig config;

  @override
  Widget build(final BuildContext context) => Padding(
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
            child: fl.RadarChart(
              fl.RadarChartData(
                dataSets: _createDataSets(),
                radarBackgroundColor: config.backgroundColor,
                radarShape: fl.RadarShape.polygon,
                gridBorderData: BorderSide(
                  color: Colors.grey.withValues(alpha: config.gridOpacity),
                ),
                tickCount: config.tickCount,
                ticksTextStyle: config.ticksTextStyle ?? TextStyle(
                  color: Colors.grey,
                  fontSize: config.ticksTextSize,
                ),
                tickBorderData: BorderSide(
                  color: Colors.grey.withValues(alpha: config.gridOpacity),
                ),
                getTitle: (final int index, final double angle) => 
                  fl.RadarChartTitle(text: index >= 0 && 
                    index < data.features.length ? data.features[index] : ""),
                      titleTextStyle: config.featuresTitleTextStyle 
                      ?? const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      radarTouchData: fl.RadarTouchData(enabled: false),
                      titlePositionPercentageOffset: 0.2,
                      radarBorderData: BorderSide(
                        color: Colors.grey.withValues(alpha: config.gridOpacity)
                      ),
              ),
            ),
          ),
          if (config.showLegend && 
            data.points.any((final APZRadarPoint point) => point.label != null))
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: data.points
                      .where((final APZRadarPoint point) => point.label != null)
                      .map((final APZRadarPoint point) => _LegendItem(
                      label: point.label!,
                      color: point.color ?? Colors.blue,
                    )).toList(),
                ),
              ),
        ],
      ),
    );

  List<fl.RadarDataSet> _createDataSets() => 
    data.points.asMap()
    .entries.map((final MapEntry<int, APZRadarPoint> entry) {
      final APZRadarPoint point = entry.value;

      return fl.RadarDataSet(
        fillColor:
            (point.color
              ?? Colors.blue)
                .withValues(alpha: config.fillArea ? 0.2 : 0),
        borderColor:
            point.color ?? Colors.blue,
        entryRadius: 3,
        dataEntries:
            point.values.map((final double value) => 
              fl.RadarEntry(value: value)).toList(),
      );
    }).toList();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty<APZRadarData>("data", data))
    ..add(DiagnosticsProperty<RadarChartConfig>("config", config));
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
