import "package:apz_charts/src/models/chart_config.dart";
import "package:apz_charts/src/models/chart_data.dart";
import "package:fl_chart/fl_chart.dart" as fl;
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// A widget that displays a scatter chart
class APZScatterChart extends StatelessWidget {

  /// Creates an APZScatterChart widget
  /// - [data] is the data to be displayed in the chart.
  /// - [config] is the configuration object that defines the appearance and
  /// behavior of the chart.
  const APZScatterChart({
    required this.data, 
    required this.config, 
    super.key,
  });

  /// The data to display in the chart
  final APZScatterData data;

  /// The configuration for the chart
  final ScatterChartConfig config;

  @override
  Widget build(final BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 400;
    final double titleFontSize = isSmallScreen ? 18.0 : 20.0;
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
              style: data.titleStyle ?? Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: fl.ScatterChart(
              fl.ScatterChartData(
                scatterSpots: _createScatterSpots(),
                titlesData: fl.FlTitlesData(
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
                      (final double value, final fl.TitleMeta meta) => 
                      Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54
                        ),
                      ),
                    ),
                    axisNameWidget: 
                      config.showLegend && config.legendTitleXAxis != null
                      ? Text(
                          config.legendTitleXAxis!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        )
                      : Container(),
                      axisNameSize: config.showLegend ? titleFontSize : 0
                  ),
                  leftTitles: fl.AxisTitles(
                    sideTitles: fl.SideTitles(
                    showTitles: true,
                    reservedSize: isSmallScreen ? 30 : 40,
                    getTitlesWidget: 
                      (final double value, final fl.TitleMeta meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 12, 
                          color: Colors.black54),
                      ),
                    ),
                    axisNameWidget: 
                      config.showLegend && config.legendTitleYAxis != null
                      ? Text(
                          config.legendTitleYAxis!,
                          style: const TextStyle(
                            fontSize: 10,
                            color:  Colors.black54,
                          ),
                        )
                      : Container(),
                    axisNameSize: config.showLegend ? titleFontSize : 0,
                  ),
                ),
                borderData: fl.FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                gridData: fl.FlGridData(
                  show: config.showGridLines,
                  drawHorizontalLine: config.showGridLines,
                  drawVerticalLine: config.showGridLines,
                  getDrawingHorizontalLine: (final double value) => fl.FlLine(
                    color: config.gridLinesXColor 
                      ?? Colors.grey.withValues(alpha: 0.2),
                    strokeWidth: 0.5,
                  ),
                  getDrawingVerticalLine: (final double value) => fl.FlLine(
                    color: config.gridLinesYColor 
                      ?? Colors.grey.withValues(alpha: 0.2),
                    strokeWidth: 0.5,
                  ),
                ),
                minX: config.minX,
                maxX: config.maxX,
                minY: config.minY,
                maxY: config.maxY,
                scatterTouchData: fl.ScatterTouchData(
                  enabled: config.showTooltips,
                  touchTooltipData: fl.ScatterTouchTooltipData(
                    tooltipBgColor:
                        config.tooltipBgColor 
                          ?? Colors.blueGrey.withValues(alpha: 0.8),
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItems: (final fl.ScatterSpot spot) => 
                      fl.ScatterTooltipItem(
                        """
                        (${spot.x.toStringAsFixed(1)},""" "${spot.y.toStringAsFixed(1)})",
                        textStyle: TextStyle(
                          color: config.tooltipTextColor ?? Colors.white,
                          fontSize: 12,
                        ),
                      ),
                  ),
                ),
              ),
            ),
          ),
          if (config.showLegend && data.series.length > 1) _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: data.series.map((final APZScatterSeries series) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: series.color ?? Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(series.name),
            ],
          )).toList(),
      ),
    );

  List<fl.ScatterSpot> _createScatterSpots() {
    final List<fl.ScatterSpot> spots = <fl.ScatterSpot>[];
    
    for (int i = 0; i < data.series.length; i++) {
      final APZScatterSeries series = data.series[i];
      for (int j = 0; j < series.points.length; j++) {
        final APZScatterPoint point = series.points[j];
        spots.add(
          fl.ScatterSpot(
            point.x,
            point.y,
            dotPainter: fl.FlDotCirclePainter(
              color: point.color ??
                  series.color ??
                  Colors.blue,
              radius: point.size ?? config.dotSize,
            ),
            show: config.showDots,
          ),
        );
      }
    }

    return spots;
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty<APZScatterData>("data", data))
    ..add(DiagnosticsProperty<ScatterChartConfig>("config", config));
  }
}
