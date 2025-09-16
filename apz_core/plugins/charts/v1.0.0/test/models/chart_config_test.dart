import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apz_charts/src/models/chart_config.dart';

void main() {
  group('BaseChartConfig', () {
    test('base configuration works with all optional parameters', () {
      const config = TestConfig(
        title: 'Test Chart',
        showLegend: true,
        padding: EdgeInsets.all(16),
        backgroundColor: Colors.white,
      );

      expect(config.title, equals('Test Chart'));
      expect(config.showLegend, isTrue);
      expect(config.padding, equals(const EdgeInsets.all(16)));
      expect(config.backgroundColor, equals(Colors.white));
    });

    test('base configuration works with defaults', () {
      const config = TestConfig();

      expect(config.title, isNull);
      expect(config.showLegend, isTrue);
      expect(config.padding, equals(const EdgeInsets.all(16)));
      expect(config.backgroundColor, isNull);
    });
  });

  group('LineChartConfig', () {
    test('creates with all optional parameters', () {
      final config = LineChartConfig(
        showDots: true,
        showArea: true,
        curved: true,
        minY: 0,
        maxY: 100,
        showGridLines: true,
        title: 'Test',
        showLegend: true,
        padding: const EdgeInsets.all(8),
        backgroundColor: Colors.white,
      );

      expect(config.showDots, isTrue);
      expect(config.showArea, isTrue);
      expect(config.curved, isTrue);
      expect(config.minY, equals(0));
      expect(config.maxY, equals(100));
      expect(config.showGridLines, isTrue);
    });

    test('creates with defaults', () {
      final config = LineChartConfig();

      expect(config.showDots, isFalse);
      expect(config.showArea, isTrue);
      expect(config.curved, isTrue);
      expect(config.minY, isNull);
      expect(config.maxY, isNull);
      expect(config.showGridLines, isTrue);
    });
  });

  group('BarChartConfig', () {
    test('creates with all optional parameters', () {
      final config = BarChartConfig(
        showValues: true,
        barColors: [Colors.blue],
        groupSpacing: 0.2,
        barSpacing: 0.1,
        minY: 0,
        maxY: 100,
        showGridLines: true,
        title: 'Test',
        showLegend: true,
        padding: const EdgeInsets.all(8),
        backgroundColor: Colors.white,
      );

      expect(config.showValues, isTrue);
      expect(config.barColors, equals([Colors.blue]));
      expect(config.groupSpacing, equals(0.2));
      expect(config.barSpacing, equals(0.1));
      expect(config.minY, equals(0));
      expect(config.maxY, equals(100));
      expect(config.showGridLines, isTrue);
    });

    test('creates with defaults', () {
      final config = BarChartConfig();

      expect(config.showValues, isTrue);
      expect(config.barColors, isNull);
      expect(config.groupSpacing, equals(0.2));
      expect(config.barSpacing, equals(0.1));
      expect(config.minY, isNull);
      expect(config.maxY, isNull);
      expect(config.showGridLines, isTrue);
    });
  });

  group('PieChartConfig', () {
    test('creates with all optional parameters', () {
      final config = PieChartConfig(
        showValues: true,
        sectionColors: [Colors.blue],
        centerSpaceRadius: 40,
        sectionSpacing: 2,
        startDegreeOffset: 0,
        title: 'Test',
        showLegend: true,
        padding: const EdgeInsets.all(8),
        backgroundColor: Colors.white,
      );

      expect(config.showValues, isTrue);
      expect(config.sectionColors, equals([Colors.blue]));
      expect(config.centerSpaceRadius, equals(40));
      expect(config.sectionSpacing, equals(2));
      expect(config.startDegreeOffset, equals(0));
    });

    test('creates with defaults', () {
      final config = PieChartConfig();

      expect(config.showValues, isTrue);
      expect(config.sectionColors, isNull);
      expect(config.centerSpaceRadius, equals(0));
      expect(config.sectionSpacing, equals(0));
      expect(config.startDegreeOffset, isNull);
    });
  });

  group('RadarChartConfig', () {
    test('creates with all optional parameters', () {
      final config = RadarChartConfig(
        fillArea: true,
        radarColors: [Colors.blue],
        gridOpacity: 0.2,
        tickCount: 5,
        ticksTextSize: 12,
        showLegend: true,
        padding: const EdgeInsets.all(8),
        backgroundColor: Colors.white,
      );

      expect(config.fillArea, isTrue);
      expect(config.radarColors, equals([Colors.blue]));
      expect(config.gridOpacity, equals(0.2));
      expect(config.tickCount, equals(5));
      expect(config.ticksTextSize, equals(12));
    });

    test('creates with defaults', () {
      final config = RadarChartConfig();

      expect(config.fillArea, isTrue);
      expect(config.radarColors, isNull);
      expect(config.gridOpacity, equals(0.2));
      expect(config.tickCount, equals(5));
      expect(config.ticksTextSize, equals(12));
    });
  });

  group('ScatterChartConfig', () {
    test('creates with all optional parameters', () {
      final config = ScatterChartConfig(
        showDots: true,
        dotSize: 8,
        showGridLines: true,
        showTooltips: true,
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 10,
        gridLinesColor: Colors.grey,
        tooltipBgColor: Colors.black,
        tooltipTextColor: Colors.white,
        legendTitleXAxis: 'X Axis',
        legendTitleYAxis: 'Y Axis',
        showLegend: true,
        padding: const EdgeInsets.all(8),
        backgroundColor: Colors.white,
      );

      expect(config.showDots, isTrue);
      expect(config.dotSize, equals(8));
      expect(config.showGridLines, isTrue);
      expect(config.showTooltips, isTrue);
      expect(config.minX, equals(0));
      expect(config.maxX, equals(10));
      expect(config.minY, equals(0));
      expect(config.maxY, equals(10));
      expect(config.gridLinesColor, equals(Colors.grey));
      expect(config.tooltipBgColor, equals(Colors.black));
      expect(config.tooltipTextColor, equals(Colors.white));
      expect(config.legendTitleXAxis, equals('X Axis'));
      expect(config.legendTitleYAxis, equals('Y Axis'));
    });

    test('creates with defaults', () {
      final config = ScatterChartConfig();

      expect(config.showDots, isTrue);
      expect(config.dotSize, equals(8));
      expect(config.showGridLines, isTrue);
      expect(config.showTooltips, isTrue);
      expect(config.minX, isNull);
      expect(config.maxX, isNull);
      expect(config.minY, isNull);
      expect(config.maxY, isNull);
      expect(config.gridLinesColor, isNull);
      expect(config.tooltipBgColor, isNull);
      expect(config.tooltipTextColor, isNull);
      expect(config.legendTitleXAxis, isNull);
      expect(config.legendTitleYAxis, isNull);
    });
  });
}

class TestConfig extends BaseChartConfig {
  const TestConfig({
    super.title,
    super.showLegend,
    super.padding,
    super.backgroundColor,
  });
}
