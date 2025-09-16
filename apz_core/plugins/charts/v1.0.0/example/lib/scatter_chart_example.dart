import "dart:math" as math;

import "package:apz_charts/apz_charts.dart";
import "package:flutter/material.dart";

/// Example usage of the APZScatterChart widget
class ScatterChartExample extends StatelessWidget {

  /// Creates an instance of ScatterChartExample
  const ScatterChartExample({super.key});

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final math.Random random = math.Random();

    // Create sample data with two series
    final List<APZScatterPoint> series1Points = 
      List<APZScatterPoint>.generate(20, (final int index) => APZScatterPoint(
        x: random.nextDouble() * 10,
        y: random.nextDouble() * 10,
        size: 8 + random.nextDouble() * 4, // Random size between 8 and 12
        label: "Point ${index + 1}",
      ));

    final List<APZScatterPoint> series2Points = 
      List<APZScatterPoint>.generate(15, (final int index) => APZScatterPoint(
        x: random.nextDouble() * 10,
        y: random.nextDouble() * 10,
        size: 8 + random.nextDouble() * 4,
        label: "Point ${index + 21}",
      ));

    return Scaffold(
      appBar: AppBar(title: const Text("Scatter Chart Example")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Random Distribution",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: APZChart(
                  type: ChartType.scatter,
                  data: APZScatterData(
                    title: "Sample Distribution",
                    series: <APZScatterSeries>[
                      APZScatterSeries(
                        name: "Series A",
                        points: series1Points,
                        color: Colors.blue,
                      ),
                      APZScatterSeries(
                        name: "Series B",
                        points: series2Points,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  config: ScatterChartConfig(
                    minX: 0,
                    maxX: 10,
                    minY: 0,
                    maxY: 10,
                    tooltipBgColor: Colors.blueGrey.withValues(alpha: 0.8),
                    tooltipTextColor: Colors.white,
                    backgroundColor: theme.colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
