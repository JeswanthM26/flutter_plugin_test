import "package:apz_charts/apz_charts.dart";
import "package:flutter/material.dart";

/// Example widget demonstrating a pie chart with monthly expenses data
class PieChartExample extends StatelessWidget {

  /// Creates a new instance of PieChartExample
  const PieChartExample({super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Pie Chart Example")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: APZChart(
          type: ChartType.pie,
          data: APZPieData(
            title: "Monthly Expenses",
            titleStyle: TextStyle(
              fontSize: 20,
            ),
            sections: <APZPieSection>[
              APZPieSection(
                value: 35,
                label: "Housing",
                color: Colors.blue,
              ),
              APZPieSection(
                value: 25,
                label: "Food",
                color: Colors.green,
              ),
              APZPieSection(
                value: 15,
                label: "Transport",
                color: Colors.orange,
              ),
              APZPieSection(
                value: 10,
                label: "Entertainment",
                color: Colors.purple,
              ),
              APZPieSection(
                value: 15,
                label: "Others",
                color: Colors.red,
              ),
            ],
          ),
          config: PieChartConfig(
            centerSpaceRadius: 80,
            sectionSpacing: 2,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
}
