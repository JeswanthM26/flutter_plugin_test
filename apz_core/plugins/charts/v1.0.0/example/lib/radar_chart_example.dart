import "package:apz_charts/apz_charts.dart";
import "package:flutter/material.dart";

/// Example widget demonstrating a radar chart with developer skills assessment
class RadarChartExample extends StatelessWidget {

  /// Creates a new instance of RadarChartExample
  const RadarChartExample({super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Radar Chart Example")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: APZChart(
          type: ChartType.radar,
          data: APZRadarData(
            title: "Developer Skills Assessment",
            features: <String>[
              "Flutter",
              "React",
              "Node.js",
              "Python",
              "SQL",
              "AWS",
            ],
            points: <APZRadarPoint>[
              APZRadarPoint(
                values: <double>[90, 70, 80, 60, 85, 75],
                label: "Developer A",
                color: Colors.blue,
              ),
              APZRadarPoint(
                values: <double>[75, 85, 65, 80, 70, 90],
                label: "Developer B",
                color: Colors.red,
              ),
            ],
          ),
          config: RadarChartConfig(
            ticksTextStyle: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w900
            ),
            featuresTitleTextStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
}
