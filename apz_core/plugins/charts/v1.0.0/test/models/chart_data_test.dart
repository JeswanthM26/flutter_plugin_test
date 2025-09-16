import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apz_charts/src/models/chart_data.dart';

void main() {
  group('APZLineData', () {
    test('creates instance with required parameters', () {
      final data = APZLineData(
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
      );

      expect(data.title, equals('Test Chart'));
      expect(data.lines.length, equals(1));
      expect(data.lines[0].points.length, equals(2));
      expect(data.lines[0].points[0].x, equals(0));
      expect(data.lines[0].points[0].y, equals(100));
      expect(data.lines[0].points[1].x, equals(1));
      expect(data.lines[0].points[1].y, equals(200));
    });

    test('equals works correctly', () {
      final data1 = APZLineData(
        title: 'Test Chart',
        lines: [
          APZLine(
            name: 'Line 1',
            points: [APZLinePoint(x: 0, y: 100)],
          ),
        ],
      );

      final data2 = APZLineData(
        title: 'Test Chart',
        lines: [
          APZLine(
            name: 'Line 1',
            points: [APZLinePoint(x: 0, y: 100)],
          ),
        ],
      );

      final data3 = APZLineData(
        title: 'Different Chart',
        lines: [
          APZLine(
            name: 'Line 1',
            points: [APZLinePoint(x: 0, y: 100)],
          ),
        ],
      );

      expect(data1, equals(data2));
      expect(data1, isNot(equals(data3)));
    });
  });

  group('APZBarData', () {
    test('creates instance with required parameters', () {
      final data = APZBarData(
        title: 'Test Chart',
        groups: [
          APZBarGroup(
            groupLabel: 'Group 1',
            items: [
              APZBarItem(value: 100, label: 'Item 1'),
              APZBarItem(value: 200, label: 'Item 2'),
            ],
          ),
        ],
      );

      expect(data.title, equals('Test Chart'));
      expect(data.groups.length, equals(1));
      expect(data.groups[0].groupLabel, equals('Group 1'));
      expect(data.groups[0].items.length, equals(2));
      expect(data.groups[0].items[0].value, equals(100));
      expect(data.groups[0].items[0].label, equals('Item 1'));
    });

    test('equals works correctly', () {
      final data1 = APZBarData(
        title: 'Test Chart',
        groups: [
          APZBarGroup(
            groupLabel: 'Group 1',
            items: [APZBarItem(value: 100)],
          ),
        ],
      );

      final data2 = APZBarData(
        title: 'Test Chart',
        groups: [
          APZBarGroup(
            groupLabel: 'Group 1',
            items: [APZBarItem(value: 100)],
          ),
        ],
      );

      final data3 = APZBarData(
        title: 'Different Chart',
        groups: [
          APZBarGroup(
            groupLabel: 'Group 1',
            items: [APZBarItem(value: 100)],
          ),
        ],
      );

      expect(data1, equals(data2));
      expect(data1, isNot(equals(data3)));
    });
  });

  group('APZPieData', () {
    test('creates instance with required parameters', () {
      final data = APZPieData(
        title: 'Test Chart',
        sections: [
          APZPieSection(value: 30, label: 'Section 1'),
          APZPieSection(value: 70, label: 'Section 2'),
        ],
      );

      expect(data.title, equals('Test Chart'));
      expect(data.sections.length, equals(2));
      expect(data.sections[0].value, equals(30));
      expect(data.sections[0].label, equals('Section 1'));
      expect(data.sections[1].value, equals(70));
      expect(data.sections[1].label, equals('Section 2'));
    });

    test('equals works correctly', () {
      final data1 = APZPieData(
        title: 'Test Chart',
        sections: [APZPieSection(value: 100, label: 'Section 1')],
      );

      final data2 = APZPieData(
        title: 'Test Chart',
        sections: [APZPieSection(value: 100, label: 'Section 1')],
      );

      final data3 = APZPieData(
        title: 'Different Chart',
        sections: [APZPieSection(value: 100, label: 'Section 1')],
      );

      expect(data1, equals(data2));
      expect(data1, isNot(equals(data3)));
    });
  });

  group('APZRadarData', () {
    test('creates instance with required parameters', () {
      final data = APZRadarData(
        title: 'Test Chart',
        features: ['Feature 1', 'Feature 2'],
        points: [
          APZRadarPoint(
            values: [80, 90],
            label: 'Point 1',
            color: Colors.blue,
          ),
        ],
      );

      expect(data.title, equals('Test Chart'));
      expect(data.features.length, equals(2));
      expect(data.features[0], equals('Feature 1'));
      expect(data.features[1], equals('Feature 2'));
      expect(data.points.length, equals(1));
      expect(data.points[0].values.length, equals(2));
      expect(data.points[0].values[0], equals(80));
      expect(data.points[0].values[1], equals(90));
      expect(data.points[0].label, equals('Point 1'));
      expect(data.points[0].color, equals(Colors.blue));
    });

    test('equals works correctly', () {
      final data1 = APZRadarData(
        title: 'Test Chart',
        features: ['Feature 1'],
        points: [APZRadarPoint(values: [80])],
      );

      final data2 = APZRadarData(
        title: 'Test Chart',
        features: ['Feature 1'],
        points: [APZRadarPoint(values: [80])],
      );

      final data3 = APZRadarData(
        title: 'Different Chart',
        features: ['Feature 1'],
        points: [APZRadarPoint(values: [80])],
      );

      expect(data1, equals(data2));
      expect(data1, isNot(equals(data3)));
    });
  });
}
