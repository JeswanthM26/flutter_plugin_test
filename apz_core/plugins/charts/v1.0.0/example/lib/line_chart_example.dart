import "package:apz_charts/apz_charts.dart";
import "package:flutter/material.dart";

/// Example widget demonstrating a line chart with multiple lines
class LineChartExample extends StatelessWidget {

  /// Creates a new instance of LineChartExample
  const LineChartExample({super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Line Chart Example")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(8),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.grey.withOpacity(0.1),
          //       spreadRadius: 2,
          //       blurRadius: 5,
          //       offset: const Offset(0, 2),
          //     ),
          //   ],
          // ),
          padding: const EdgeInsets.all(16),
          child: const APZChart(
            type: ChartType.line,
            data: APZLineData(
              title: "Project Metrics Over Time",
              titleStyle: TextStyle(fontSize: 20),
              lines: <APZLine>[
                APZLine(
                  name: "Task Completion",
                  points: <APZLinePoint>[
                    APZLinePoint(x: 0, y: 10, label: "Week 1"),
                    APZLinePoint(x: 1, y: 25, label: "Week 2"),
                    APZLinePoint(x: 2, y: 45, label: "Week 3"),
                    APZLinePoint(x: 3, y: 60, label: "Week 4"),
                    APZLinePoint(x: 4, y: 85, label: "Week 5"),
                  ],
                  color: Colors.green,
                ),
                APZLine(
                  name: "Bug Count",
                  points: <APZLinePoint>[
                    APZLinePoint(x: 0, y: 50, label: "Week 1"),
                    APZLinePoint(x: 1, y: 40, label: "Week 2"),
                    APZLinePoint(x: 2, y: 30, label: "Week 3"),
                    APZLinePoint(x: 3, y: 20, label: "Week 4"),
                    APZLinePoint(x: 4, y: 10, label: "Week 5"),
                  ],
                  color: Colors.red,
                ),
                APZLine(
                  name: "Team Velocity",
                  points: <APZLinePoint>[
                    APZLinePoint(x: 0, y: 30, label: "Week 1"),
                    APZLinePoint(x: 1, y: 45, label: "Week 2"),
                    APZLinePoint(x: 2, y: 55, label: "Week 3"),
                    APZLinePoint(x: 3, y: 70, label: "Week 4"),
                    APZLinePoint(x: 4, y: 90, label: "Week 5"),
                  ],
                  color: Colors.blue,
                ),
              ],
            ),
            config: LineChartConfig(
              minY: 0,
              maxY: 100,
              legendTitleXAxis: "Time",
              legendTitleYAxis: "Value",
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(24),
            ),
          ),
        ),
      ),
    );
}
