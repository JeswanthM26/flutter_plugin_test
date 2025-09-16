import "package:example/bar_chart_example.dart";
import "package:example/line_chart_example.dart";
import "package:example/pie_chart_example.dart";
import "package:example/radar_chart_example.dart";
import "package:example/scatter_chart_example.dart";
import "package:flutter/material.dart";

void main() {
  runApp(const ExampleApp());
}

/// Main application widget that serves as the entry point for the example app
class ExampleApp extends StatelessWidget {

  /// Creates an instance of ExampleApp
  const ExampleApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
      title: "APZ Charts Examples",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ExampleList(),
    );
}

/// A list of example charts demonstrating different chart types
class ExampleList extends StatelessWidget {

  /// Creates an instance of ExampleList
  const ExampleList({super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("APZ Charts Examples")),
      body: ListView(
        children: <Widget>[
          _buildExampleTile(
            context,
            "Line Chart",
            "Time series data visualization",
            const LineChartExample(),
          ),
          _buildExampleTile(
            context,
            "Bar Chart",
            "Categorical data comparison",
            const BarChartExample(),
          ),
          _buildExampleTile(
            context,
            "Pie Chart",
            "Part-to-whole relationships",
            const PieChartExample(),
          ),
          _buildExampleTile(
            context,
            "Radar Chart",
            "Multi-variable data comparison",
            const RadarChartExample(),
          ),
          _buildExampleTile(
            context,
            "Scatter Chart",
            "Data point distribution visualization",
            const ScatterChartExample(),
          ),
        ],
      ),
    );

  Widget _buildExampleTile(
    final BuildContext context,
    final String title,
    final String subtitle,
    final Widget example,
  ) => ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<dynamic>(
            builder: (final BuildContext context) => example),
        );
      },
    );
}
