import "package:apz_charts/apz_charts.dart";
import "package:flutter/material.dart";

/// Example widget demonstrating a bar chart with quarterly sales data
class BarChartExample extends StatelessWidget {

  /// Creates a new instance of BarChartExample
  const BarChartExample({super.key});

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Bar Chart Example")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: APZChart(
          type: ChartType.bar,
          data: const APZBarData(
            title: "Quarterly Sales by Product",
            groups: <APZBarGroup>[
              APZBarGroup(
                groupLabel: "Q1",
                items: <APZBarItem>[
                  APZBarItem(value: 100, label: "Product A", 
                    color: Colors.blue),
                  APZBarItem(value: 150, label: "Product B", 
                    color: Colors.green),
                  APZBarItem(value: 120, label: "Product C", 
                    color: Colors.orange),
                ],
              ),
              APZBarGroup(
                groupLabel: "Q2",
                items: <APZBarItem>[
                  APZBarItem(value: 130, label: "Product A", 
                    color: Colors.blue),
                  APZBarItem(value: 180, label: "Product B", 
                    color: Colors.green),
                  APZBarItem(value: 160, label: "Product C", 
                    color: Colors.orange),
                ],
              ),
              APZBarGroup(
                groupLabel: "Q3",
                items: <APZBarItem>[
                  APZBarItem(value: 90, label: "Product A", 
                    color: Colors.blue, width: 10),
                  APZBarItem(value: 200, label: "Product B",
                    color: Colors.green),
                  APZBarItem(value: 140, label: "Product C",
                    color: Colors.orange),
                ],
              ),
            ],
          ),
          config: BarChartConfig(
            minY: 0,
            maxY: 250,
            backgroundColor: theme.colorScheme.surface,
          ),
        ),
      ),
    );
  }
}
