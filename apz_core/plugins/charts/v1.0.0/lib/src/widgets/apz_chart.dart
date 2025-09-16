import "package:apz_charts/src/enums/chart_type.dart";
import "package:apz_charts/src/models/chart_config.dart";
import "package:apz_charts/src/models/chart_data.dart";
import "package:apz_charts/src/widgets/charts/bar_chart_widget.dart";
import "package:apz_charts/src/widgets/charts/line_chart_widget.dart";
import "package:apz_charts/src/widgets/charts/pie_chart_widget.dart";
import "package:apz_charts/src/widgets/charts/radar_chart_widget.dart";
import "package:apz_charts/src/widgets/charts/scatter_chart_widget.dart";
import "package:flutter/material.dart";

/// A unified chart widget that supports multiple chart types
class APZChart extends StatelessWidget {

  /// Creates an APZChart widget
  /// - [type] specifies the type of chart to display 
  /// (e.g., Line, Bar, Pie, Radar).
  /// - [data] is the data to be displayed in the chart.
  /// - [config] is the configuration object that defines the appearance and 
  /// behavior of the chart.
  const APZChart({
    required final ChartType type,
    required final BaseChartData data,
    required final BaseChartConfig config,
    super.key,
  }): _type = type,
      _data = data,
      _config = config;
      

  /// The type of chart to display
  /// - [_type] specifies the type of chart to display 
  /// (e.g., Line, Bar, Pie, Radar).
  final ChartType _type;

  /// The data to display on the chart
  /// - [_data] is the data object that contains the information to be 
  /// visualized in the chart.
  final BaseChartData _data;

  /// The configuration for the chart
  /// - [_config] is the configuration object that defines the appearance and 
  /// behavior of the chart.
  final BaseChartConfig _config;

  @override
  Widget build(final BuildContext context) => _buildChart();

  Widget _buildChart() {
    switch (_type) {
      case ChartType.line:
        if (_data is! APZLineData || _config is! LineChartConfig) {
          throw ArgumentError("Invalid data or config type for LineChart");
        }
        return APZLineChart(
          data: _data,
          config: _config,
        );
      
      case ChartType.bar:
        if (_data is! APZBarData || _config is! BarChartConfig) {
          throw ArgumentError("Invalid data or config type for BarChart");
        }
        return APZBarChart(
          data: _data,
          config: _config,
        );
      
      case ChartType.pie:
        if (_data is! APZPieData || _config is! PieChartConfig) {
          throw ArgumentError("Invalid data or config type for PieChart");
        }
        return APZPieChart(
          data: _data,
          config: _config,
        );
      
      case ChartType.radar:
        if (_data is! APZRadarData || _config is! RadarChartConfig) {
          throw ArgumentError("Invalid data or config type for RadarChart");
        }
        return APZRadarChart(
          data: _data,
          config: _config,
        );
        
      case ChartType.scatter:
        if (_data is! APZScatterData || _config is! ScatterChartConfig) {
          throw ArgumentError("Invalid data or config type for ScatterChart");
        }
        return APZScatterChart(
          data: _data,
          config: _config,
        );
    }
  }
}
