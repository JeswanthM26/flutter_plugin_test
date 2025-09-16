import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apz_charts/apz_charts.dart';

void main() {
  group('APZChart Widget', () {
    testWidgets('renders line chart correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: APZChart(
              type: ChartType.line,
              data: APZLineData(
                title: 'Test Chart',
                lines: [
                  APZLine(
                    name: 'Line 1',
                    points: [
                      APZLinePoint(x: 0, y: 100),
                      APZLinePoint(x: 1, y: 200),
                    ],
                  ),
                ],
              ),
              config: LineChartConfig(
                showDots: true,
                showArea: true,
                curved: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Chart'), findsOneWidget);
    });

    testWidgets('renders bar chart correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: APZChart(
              type: ChartType.bar,
              data: APZBarData(
                title: 'Test Chart',
                groups: [
                  APZBarGroup(
                    groupLabel: 'Group 1',
                    items: [APZBarItem(value: 100, label: 'Item 1')],
                  ),
                ],
              ),
              config: BarChartConfig(
                showValues: true,
                showGridLines: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Chart'), findsOneWidget);
    });

    testWidgets('renders pie chart correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: APZChart(
              type: ChartType.pie,
              data: APZPieData(
                title: 'Test Chart',
                sections: [
                  APZPieSection(value: 100, label: 'Section 1'),
                ],
              ),
              config: PieChartConfig(
                showValues: true,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Chart'), findsOneWidget);
    });

    testWidgets('renders radar chart correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: APZChart(
              type: ChartType.radar,
              data: APZRadarData(
                title: 'Test Chart',
                features: ['Feature 1', 'Feature 2', 'Feature 3'],
                points: [
                  APZRadarPoint(values: [80, 90, 85], label: 'Point 1'),
                ],
              ),
              config: RadarChartConfig(
                fillArea: true,
                gridOpacity: 0.2,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Chart'), findsOneWidget);
    });

    testWidgets('renders scatter chart correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: APZChart(
              type: ChartType.scatter,
              data: APZScatterData(
                series: [
                  APZScatterSeries(
                    name: 'Series 1',
                    points: [
                      APZScatterPoint(x: 1, y: 1),
                      APZScatterPoint(x: 2, y: 2),
                    ],
                  ),
                ],
              ),
              config: ScatterChartConfig(
                showDots: true,
                dotSize: 8,
                showGridLines: true,
                showTooltips: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(APZChart), findsOneWidget);
    });

    testWidgets('throws for mismatched data and config types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return APZChart(
                type: ChartType.line,
                data: APZBarData(
                  title: 'Test Chart',
                  groups: [],
                ),
                config: LineChartConfig(),
              );
            },
          ),
        ),
      );

      expect(tester.takeException(), isA<ArgumentError>());
    });
  });
}
