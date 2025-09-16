import "package:apz_charts/src/models/chart_config.dart";
import "package:apz_charts/src/models/chart_data.dart";
import "package:fl_chart/fl_chart.dart" as fl;
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// A widget that displays a line chart
class APZLineChart extends StatelessWidget {

  /// Creates an APZLineChart widget
  /// - [data] is the data to be displayed in the chart.
  /// - [config] is the configuration object that defines the appearance and 
  /// behavior of the chart
  const APZLineChart({
    required this.data, 
    required this.config, 
    super.key,
  });
  
  /// The data to display in the chart
  final APZLineData data;

  /// The configuration for the chart
  final LineChartConfig config;

  @override
  Widget build(final BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 400;
    final double titleFontSize = isSmallScreen ? 18.0 : 20.0;
    const double reservedeSize = 44;

    return Column(
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
          child: fl.LineChart(
            duration: const Duration(milliseconds: 300),
            fl.LineChartData(
              gridData: fl.FlGridData(
                show: config.showGridLines,
                drawHorizontalLine: config.showGridLines,
                drawVerticalLine: config.showGridLines,
                getDrawingHorizontalLine: (final double value) => 
                fl.FlLine(
                  color: config.gridLinesXColor 
                    ?? Colors.grey.withValues(alpha: 0.3),
                  strokeWidth: 0.5,
                ),
                getDrawingVerticalLine: (final double value) => 
                fl.FlLine(
                  color: config.gridLinesYColor 
                    ?? Colors.grey.withValues(alpha: 0.3),
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
                    (final double value, final fl.TitleMeta meta) => 
                    Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 12, color: 
                        config.chartLabelsXColor ?? Colors.black54),
                    ),
                  ),
                  axisNameWidget: 
                    config.showLegend && config.legendTitleXAxis != null
                    ? Text(
                        config.legendTitleXAxis!,
                        style: TextStyle(
                          fontSize: 10,
                          color: config.chartLabelsXColor ?? Colors.black54,
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
                      style: TextStyle(
                        fontSize: 12, 
                        color: config.chartLabelsYColor ?? Colors.black54),
                    ),
                  ),
                  axisNameWidget: 
                    config.showLegend && config.legendTitleYAxis != null
                    ? Text(
                        config.legendTitleYAxis!,
                        style: TextStyle(
                          fontSize: 10,
                          color: config.chartLabelsYColor ?? Colors.black54,
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
              minY: config.minY,
              maxY: config.maxY,
              lineBarsData: data.lines
                .asMap().entries.map((final MapEntry<int, APZLine> entry) {
                final APZLine line = entry.value;
                final Color color = line.color ?? Colors.blue;
    
                return fl.LineChartBarData(
                  spots: line.points
                      .map((final APZLinePoint point) => 
                        fl.FlSpot(point.x, point.y))
                        .toList(),
                  isCurved: config.curved,
                  color: color,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: fl.FlDotData(
                    show: config.showDots,
                    getDotPainter: 
                      (final fl.FlSpot spot, 
                      final double percent, 
                      final fl.LineChartBarData barData, 
                      final int index) => fl.FlDotCirclePainter(
                          radius: 6,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: fl.BarAreaData(
                    show: config.showArea,
                    gradient: LinearGradient(
                      colors: <Color>[
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                );
              }).toList(),
              lineTouchData: fl.LineTouchData(
                touchTooltipData: fl.LineTouchTooltipData(
                  tooltipBgColor: config.dataTooltipBgColor ?? Colors.black87,
                  getTooltipItems: 
                    (final List<fl.LineBarSpot> touchedBarSpots) => 
                      touchedBarSpots.map((final fl.LineBarSpot barSpot) {
                        final APZLine line = data.lines[barSpot.barIndex];
                        final APZLinePoint point = 
                          line.points[barSpot.x.toInt()];
                        return fl.LineTooltipItem(
                          "${line.name}: ${barSpot.y.toStringAsFixed(1)}",
                          TextStyle(
                            color: config.dataTooltipTextColor ?? Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            if (point.label != null)
                              TextSpan(
                                text: "\n${point.label}",
                                style: TextStyle(
                                  color: config.dataTooltipTextColor
                                    ?.withValues(alpha: 0.8) ?? Colors.white70,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                ),
              ),
              backgroundColor: 
                config.backgroundColor ?? Colors.transparent,
            ),
          ),
        ),
        if (config.showLegend)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: data.lines.asMap().entries
                .map((final MapEntry<int, APZLine> entry) {
                  final APZLine line = entry.value;
                  final Color color = line.color ?? Colors.blue;
      
                  return Row(
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
                        line.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
            ),
          ),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty<APZLineData>("data", data))
    ..add(DiagnosticsProperty<LineChartConfig>("config", config));
  }
}
