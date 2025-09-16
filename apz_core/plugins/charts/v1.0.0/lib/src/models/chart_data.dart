import "package:equatable/equatable.dart";
import "package:flutter/material.dart";

/// Base class for all chart data models
abstract class BaseChartData extends Equatable {
  /// Creates a base chart data instance
  const BaseChartData();
}

/// Data model for Scatter Chart
class APZScatterData extends BaseChartData {
  /// Creates a configuration for Scatter Chart
  /// - [series] is a list of [APZScatterSeries] objects, each representing a
  /// series of scatter points
  /// - [title] is the title of the scatter chart
  /// - [titleStyle] is the style for the title text
  const APZScatterData({required this.series, this.title, this.titleStyle});

  /// List of scatter point series in the chart
  /// Each series has its own points, name, and color
  final List<APZScatterSeries> series;

  /// Title of the scatter chart
  final String? title;

  /// Style for the title
  final TextStyle? titleStyle;

  @override
  List<Object?> get props => <Object?>[series, title, titleStyle];
}

/// Represents a series of scatter points
class APZScatterSeries extends Equatable {
  /// Creates a scatter series configuration
  /// - [name] is the name of the series (shown in legend)
  /// - [points] is a list of points in the series
  /// - [color] is the color of the points (optional)
  const APZScatterSeries({
    required this.name,
    required this.points,
    this.color,
  });

  /// Name of the series (shown in legend)
  final String name;

  /// Color of the series points
  final Color? color;

  /// List of points in the series
  final List<APZScatterPoint> points;

  @override
  List<Object?> get props => <Object?>[name, points, color];
}

/// Data point for Scatter Chart
class APZScatterPoint extends Equatable {
  /// Creates a scatter point
  /// - [x] is the x-coordinate of the point
  /// - [y] is the y-coordinate of the point
  /// - [size] is the size of the point (optional)
  /// - [label] is the label for the point (shown on hover)
  /// - [color] overrides the series color for this point
  const APZScatterPoint({
    required this.x,
    required this.y,
    this.size,
    this.label,
    this.color,
  });

  /// The x-coordinate of the point
  final double x;

  /// The y-coordinate of the point
  final double y;

  /// The size of the point (optional)
  final double? size;

  /// Label for the point (shown on hover)
  final String? label;

  /// Color override for individual point
  final Color? color;

  @override
  List<Object?> get props => <Object?>[x, y, size, label, color];
}

/// Data model for Line Chart
class APZLineData extends BaseChartData {
  /// Creates a configuration for Line Chart
  /// - [lines] is a list of [APZLine] objects,
  /// each representing a line in the chart
  /// - [title] is the title of the line chart
  /// - [titleStyle] is the style for the title text
  const APZLineData({required this.lines, this.title, this.titleStyle});

  /// List of lines in the chart
  /// Each line has its own points, name, and color
  /// - [lines] is a list of [APZLine] objects,
  ///  each representing a line in the chart
  final List<APZLine> lines;

  /// Title of the line chart
  /// - [title] is the title of the line chart
  final String? title;

  /// Style for the title of the line chart
  /// - [titleStyle] is the style for the title text
  final TextStyle? titleStyle;

  @override
  List<Object?> get props => <Object?>[lines, title, titleStyle];
}

/// Represents a single line in the chart
class APZLine extends Equatable {
  /// Creates a line configuration
  /// - [name] is the name of the line (shown in legend)
  /// - [points] is a list of points that make up the line
  /// - [color] is the color of the line (optional)
  const APZLine({required this.name, required this.points, this.color});

  /// Name of the line (shown in legend)
  /// - [name] is the name of the line
  final String name;

  /// Color of the line
  /// - [color] is the color of the line (optional)
  final Color? color;

  /// List of points that make up the line
  /// - [points] is a list of [APZLinePoint] objects, each representing
  /// a point in the line
  final List<APZLinePoint> points;

  @override
  List<Object?> get props => <Object?>[name, points, color];
}

/// Data point for Line Chart
class APZLinePoint extends Equatable {
  /// Creates a point for the line chart
  /// - [x] is the x-coordinate of the point
  /// - [y] is the y-coordinate of the point
  /// - [label] is an optional label for the point (shown on hover)
  const APZLinePoint({required this.x, required this.y, this.label});

  /// - [x] is the x-coordinate of the point
  final double x;

  /// - [y] is the y-coordinate of the point
  final double y;

  /// - [label] is an optional label for the point (shown on hover)
  final String? label;

  @override
  List<Object?> get props => <Object?>[x, y, label];
}

/// Data model for Bar Chart
class APZBarData extends BaseChartData {
  /// Creates a configuration for Bar Chart
  /// - [groups] is a list of [APZBarGroup] objects, each representing
  /// a group in the bar chart
  /// - [title] is the title of the bar chart
  /// - [titleStyle] is the style for the title text
  const APZBarData({required this.groups, this.title, this.titleStyle});

  /// List of groups in the bar chart
  /// Each group has its own items, label, and optional color
  /// - [groups] is a list of [APZBarGroup] objects, each representing
  /// a group in the bar chart
  final List<APZBarGroup> groups;

  /// Title of the bar chart
  /// - [title] is the title of the bar chart
  final String? title;

  /// Style for the title of the bar chart
  /// - [titleStyle] is the style for the title text
  final TextStyle? titleStyle;

  @override
  List<Object?> get props => <Object?>[groups, title, titleStyle];
}

/// Data group for Bar Chart
class APZBarGroup extends Equatable {
  /// Creates a group for the bar chart
  /// - [groupLabel] is the label for the group (shown in legend)
  /// - [items] is a list of [APZBarItem] objects, each representing a bar
  /// item in the group
  const APZBarGroup({required this.groupLabel, required this.items});

  /// Label for the group (shown in legend)
  /// - [groupLabel] is the label for the group (shown in legend)
  final String groupLabel;

  /// List of items in the group
  /// - [items] is a list of [APZBarItem] objects, each
  final List<APZBarItem> items;

  @override
  List<Object?> get props => <Object?>[groupLabel, items];
}

/// Data item for Bar Chart
class APZBarItem extends Equatable {
  /// Creates a bar item for the bar chart
  /// - [value] is the value of the bar (height of the bar)
  /// - [label] is an optional label for the bar (shown in legend)
  /// - [color] is the color of the bar (optional)
  /// - [width] is the width of the bar (optional)
  const APZBarItem({required this.value, this.label, this.color, this.width});

  /// - [value] is the value of the bar (height of the bar)
  final double value;

  /// - [label] is an optional label for the bar (shown in legend)
  final String? label;

  /// - [color] is the color of the bar (optional)
  final Color? color;

  /// - [width] is the width of the bar (optional)
  final double? width;

  @override
  List<Object?> get props => <Object?>[value, label, color, width];
}

/// Data model for Pie Chart
class APZPieData extends BaseChartData {
  /// Creates a configuration for Pie Chart
  /// - [sections] is a list of [APZPieSection] objects, each representing a
  /// section in the pie chart
  /// - [title] is the title of the pie chart
  /// - [titleStyle] is the style for the title text
  const APZPieData({required this.sections, this.title, this.titleStyle});

  /// List of sections in the pie chart
  /// Each section has its own value, label, and optional color
  /// - [sections] is a list of [APZPieSection] objects, each
  final List<APZPieSection> sections;

  /// Title of the pie chart
  /// - [title] is the title of the pie chart
  final String? title;

  /// Style for the title of the pie chart
  /// - [titleStyle] is the style for the title text
  final TextStyle? titleStyle;

  @override
  List<Object?> get props => <Object?>[sections, title, titleStyle];
}

/// Data section for Pie Chart
class APZPieSection extends Equatable {
  /// Creates a section for the pie chart
  /// - [value] is the value of the section (percentage of the pie)
  /// - [label] is the label for the section (shown in legend)
  /// - [color] is the color of the section (optional)
  const APZPieSection({required this.value, required this.label, this.color});

  /// - [value] is the value of the section (percentage of the pie)
  final double value;

  /// - [label] is the label for the section (shown in legend)
  final String label;

  /// - [color] is the color of the section (optional)
  final Color? color;

  @override
  List<Object?> get props => <Object?>[value, label, color];
}

/// Data model for Radar Chart
class APZRadarData extends BaseChartData {
  /// Creates a configuration for Radar Chart
  /// - [points] is a list of [APZRadarPoint] objects, each representing a
  /// point in the radar chart
  /// - [features] is a list of feature names
  /// - [title] is the title of the radar chart
  /// - [titleStyle] is the style for the title text
  const APZRadarData({
    required this.points,
    required this.features,
    this.title,
    this.titleStyle,
  });

  /// List of points in the radar chart
  /// Each point has its own values, label, and optional color
  /// - [points] is a list of [APZRadarPoint] objects, each representing a
  /// point in the radar chart
  final List<APZRadarPoint> points;

  /// List of feature names in the radar chart
  /// - [features] is a list of feature names
  final List<String> features;

  /// Title of the radar chart
  /// - [title] is the title of the radar chart
  final String? title;

  /// Style for the title of the radar chart
  /// - [titleStyle] is the style for the title text
  final TextStyle? titleStyle;

  @override
  List<Object?> get props => <Object?>[points, features, title, titleStyle];
}

/// Data point for Radar Chart
class APZRadarPoint extends Equatable {
  /// Creates a point for the radar chart
  /// - [values] is a list of values for the point (one for each feature)
  /// - [label] is an optional label for the point (shown in legend)
  /// - [color] is the color of the point (optional)
  const APZRadarPoint({required this.values, this.label, this.color});

  /// - [values] is a list of values for the point (one for each feature)
  final List<double> values;

  /// - [label] is an optional label for the point (shown in legend)
  final String? label;

  /// - [color] is the color of the point (optional)
  final Color? color;

  @override
  List<Object?> get props => <Object?>[values, label, color];
}
