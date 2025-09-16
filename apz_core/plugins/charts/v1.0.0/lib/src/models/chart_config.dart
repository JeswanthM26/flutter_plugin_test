import "package:flutter/material.dart";

/// Base configuration class for all chart types
abstract class BaseChartConfig {

  /// Creates a base configuration for charts
  /// - [title] is the title of the chart (optional)
  /// - [showLegend] indicates whether to show the legend (default is true)
  /// - [legendTitleXAxis] is the title for the X-axis in the legend (optional)
  /// - [legendTitleYAxis] is the title for the Y-axis in the legend (optional)
  /// - [padding] is the padding around the chart (default = EdgeInsets.all(16))
  /// - [backgroundColor] is the background color of the chart (optional)
  const BaseChartConfig({
    this.title,
    this.showLegend = true,
    this.legendTitleXAxis,
    this.legendTitleYAxis,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  });

  /// - [title] is the title of the chart.`
  final String? title;

  /// - [showLegend] indicates whether to show the legend (X & Y axes titles).
  final bool showLegend;

  /// - [legendTitleXAxis] is the title for the X-axis in the legend.
  final String? legendTitleXAxis;

  /// - [legendTitleYAxis] is the title for the Y-axis in the legend.
  final String? legendTitleYAxis;

  /// - [padding] is the padding around the chart.
  final EdgeInsets padding;

  /// - [backgroundColor] is the background color of the chart.
  final Color? backgroundColor;
}

/// Configuration for Line Chart
class LineChartConfig extends BaseChartConfig {

  /// Creates a configuration for Line Chart
  /// - [showDots] indicates to show dots on the data line (default is false)
  /// - [showArea] indicates to fill the area under the data line (default true)
  /// - [areaColor] is the color of the area under the data line (optional)
  /// - [curved] indicates the data line should be curved (default is true)
  /// - [minY] is the minimum value for the Y-axis (optional)
  /// - [maxY] is the maximum value for the Y-axis (optional)
  /// - [showGridLines] indicates whether to show grid lines (default is true)
  /// - [gridLinesXColor] is the color of the horizontal grid lines (optional)
  /// - [gridLinesYColor] is the color of the vertical grid lines (optional)
  /// - [chartLabelsXColor] is the color of the X-axis labels (optional)
  /// - [chartLabelsYColor] is the color of the Y-axis labels (optional)
  /// - [dataTooltipBgColor] is the background color of data tooltip (optional)
  /// - [dataTooltipTextColor] is the text color of the data tooltip (optional)
  /// - [dataLineColor] is the default color of the line in the chart (optional)
  const LineChartConfig({
    super.title,
    super.showLegend,
    super.legendTitleXAxis,
    super.legendTitleYAxis,
    super.padding,
    super.backgroundColor,
    this.showDots = false,
    this.showArea = true,
    this.areaColor,
    this.curved = true,
    this.minY,
    this.maxY,
    this.showGridLines = true,
    this.gridLinesXColor,
    this.gridLinesYColor,
    this.chartLabelsXColor,
    this.chartLabelsYColor,
    this.dataTooltipBgColor,
    this.dataTooltipTextColor,
    this.dataLineColor,
  });

  /// - [showDots] indicates whether to show dots on the data line.
  final bool showDots;

  /// - [showArea] indicates whether to fill the area under the data line.
  final bool showArea;

  /// - [areaColor] is the color of the area under the data line.
  final Color? areaColor;

  /// - [curved] indicates whether the data line should be curved.
  final bool curved;

  /// - [minY] is the minimum value for the Y-axis.
  final double? minY;

  /// - [maxY] is the maximum value for the Y-axis.
  final double? maxY;

  /// - [showGridLines] indicates whether to show grid lines.
  final bool showGridLines;

  /// - [gridLinesXColor] is the color of the horizontal grid lines.
  final Color? gridLinesXColor;

  /// - [gridLinesYColor] is the color of the vertical grid lines.
  final Color? gridLinesYColor;

  /// - [chartLabelsXColor] is the color of the X-axis labels.
  final Color? chartLabelsXColor;

  /// - [chartLabelsYColor] is the color of the Y-axis labels.
  final Color? chartLabelsYColor;

  /// - [dataTooltipBgColor] is the background color of the data tooltip.
  final Color? dataTooltipBgColor;

  /// - [dataTooltipTextColor] is the text color of the data tooltip.
  final Color? dataTooltipTextColor;

  /// - [dataLineColor] is the default color of the line in the chart.
  final Color? dataLineColor;
}

/// Configuration for Bar Chart
class BarChartConfig extends BaseChartConfig {

  /// Creates a configuration for Bar Chart
  /// - [groupSpacing] is the spacing between groups of bars 
  /// (only in grouped type)
  /// - [barSpacing] is the spacing between bars in same group 
  /// (only in grouped type)
  /// - [barWidth] is the width of individual bars (optional)
  /// - [showValues] indicates whether to show values on top of bars 
  /// (default is true)
  /// - [minY] is the minimum value for Y axis (optional)
  /// - [maxY] is the maximum value for Y axis (optional)
  /// - [showGridLines] indicates whether to show grid lines (default is true)
  /// - [borderRadius] is the border radius for bars (default is 4)
  /// (optional)
  /// - [showLegend] indicates whether to show the legend (default is true)
  /// - [padding] is the padding around the chart (default = EdgeInsets.all(16))
  /// - [backgroundColor] is the background color of the chart (optional)
  const BarChartConfig({
    super.title,
    super.showLegend,
    super.padding,
    super.backgroundColor,
    this.groupSpacing = 0.2,
    this.barSpacing = 0.1,
    this.barWidth,
    this.showValues = true,
    this.minY,
    this.maxY,
    this.showGridLines = true,
    this.borderRadius = 4,
  });

  /// - [groupSpacing] is the spacing between groups of bars
  final double groupSpacing;

  /// - [barSpacing] is the spacing between bars in same group
  final double barSpacing;

  /// - [barWidth] is the width of individual bars (optional).
  final double? barWidth;

  /// - [showValues] indicates whether to show values on top of bars.
  final bool showValues;

  /// - [minY] is the minimum value for Y axis (optional).
  final double? minY;

  /// - [maxY] is the maximum value for Y axis (optional).
  final double? maxY;

  /// - [showGridLines] indicates whether to show grid lines.
  final bool showGridLines;

  /// - [borderRadius] is the border radius for bars (optional).
  final double? borderRadius;
}

/// Configuration for Pie Chart
class PieChartConfig extends BaseChartConfig {

  /// Creates a configuration for Pie Chart
  /// - [centerSpaceRadius] is the radius of the center space in the pie chart
  /// - [sectionSpacing] is the spacing between sections in the pie chart
  /// - [showValues] indicates whether to show values in the pie chart sections
  /// - [startDegreeOffset] is the starting degree offset for the pie chart
  ///  (useful for rotating the pie chart)
  const PieChartConfig({
    super.title,
    super.showLegend,
    super.padding,
    super.backgroundColor,
    this.centerSpaceRadius = 0,
    this.sectionSpacing = 0,
    this.showValues = true,
    this.startDegreeOffset,
  });

  /// - [centerSpaceRadius] is the radius of the center space in the pie chart.
  final double centerSpaceRadius;

  /// - [sectionSpacing] is the spacing between sections in the pie chart.
  final double sectionSpacing;

  /// - [showValues] indicates whether to show values in the pie chart sections.
  final bool showValues;

  /// - [startDegreeOffset] is the starting degree offset for the pie chart
  final double? startDegreeOffset;
}

/// Configuration for Radar Chart
class RadarChartConfig extends BaseChartConfig {

  /// Creates a configuration for Radar Chart
  /// - [featuresTitleTextStyle] is the style for the title text (optional)
  /// - [fillArea] indicates whether to fill the area under the radar chart 
  /// (default true)
  /// - [gridOpacity] is the opacity of the grid lines (default is 0.2)
  /// - [tickCount] is the number of ticks on the radar chart (default is 5)
  /// - [ticksTextSize] is the font size for the ticks text (default is 12)
  /// - [ticksTextStyle] is the style for the ticks text (optional)
  /// - [showLegend] indicates whether to show the legend (default is true)
  /// - [padding] is the padding around the chart (default = EdgeInsets.all(16))
  /// - [backgroundColor] is the background color of the chart (optional)
  const RadarChartConfig({
    super.showLegend,
    super.padding,
    super.backgroundColor,
    this.fillArea = true,
    this.gridOpacity = 0.2,
    this.tickCount = 5,
    this.ticksTextSize = 12, 
    this.ticksTextStyle, 
    this.featuresTitleTextStyle,
  });

  /// - [fillArea] indicates whether to fill the area under the radar chart 
  /// (default = true).
  final bool fillArea;

  /// - [gridOpacity] is the opacity of the grid lines (default is 0.2).
  final double gridOpacity;

  /// - [tickCount] is the number of ticks on the radar chart (default is 5).
  final int tickCount;

  /// - [ticksTextSize] is the font size for the ticks text (default is 12).
  final double ticksTextSize;

  /// - [ticksTextStyle] is the style for the ticks text (optional).
  final TextStyle? ticksTextStyle;

  /// - [featuresTitleTextStyle] is the style for the title text (optional).
  final TextStyle? featuresTitleTextStyle;
}

/// Configuration for Scatter Chart
class ScatterChartConfig extends BaseChartConfig {
  /// Creates a configuration for Scatter Chart
  /// - [showDots] indicates whether to show dots (default is true)
  /// - [dotSize] is the default size of the dots (default is 8.0)
  /// - [minX] is the minimum value for X axis (optional)
  /// - [maxX] is the maximum value for X axis (optional)
  /// - [minY] is the minimum value for Y axis (optional)
  /// - [maxY] is the maximum value for Y axis (optional)
  /// - [showGridLines] indicates whether to show grid lines (default is true)
  /// - [gridLinesColor] is the color of the grid lines (optional)
  /// - [gridLinesXColor] is the color of the horizontal grid lines (optional)
  /// - [gridLinesYColor] is the color of the vertical grid lines (optional)
  /// - [showTooltips] indicates whether to show tooltips on hover 
  /// (default is true)
  /// - [tooltipBgColor] is the background color of the tooltip (optional)
  /// - [tooltipTextColor] is the text color of the tooltip (optional)
  const ScatterChartConfig({
    super.title,
    super.showLegend,
    super.legendTitleXAxis,
    super.legendTitleYAxis,
    super.padding,
    super.backgroundColor,
    this.showDots = true,
    this.dotSize = 8.0,
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
    this.showGridLines = true,
    this.gridLinesColor,
    this.gridLinesXColor,
    this.gridLinesYColor,
    this.showTooltips = true,
    this.tooltipBgColor,
    this.tooltipTextColor,
  });

  /// Whether to show dots
  final bool showDots;

  /// Default size of the dots
  final double dotSize;

  /// Minimum value for X axis
  final double? minX;

  /// Maximum value for X axis
  final double? maxX;

  /// Minimum value for Y axis
  final double? minY;

  /// Maximum value for Y axis
  final double? maxY;

  /// Whether to show grid lines
  final bool showGridLines;

  /// Color of the grid lines
  final Color? gridLinesColor;

  /// Color of the horizontal grid lines
  final Color? gridLinesXColor;

  /// Color of the vertical grid lines
  final Color? gridLinesYColor;

  /// Whether to show tooltips on hover
  final bool showTooltips;

  /// Background color of the tooltip
  final Color? tooltipBgColor;

  /// Text color of the tooltip
  final Color? tooltipTextColor;
}
