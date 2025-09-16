# APZ Charts

A Flutter charting package that provides an intuitive abstraction layer over `fl_chart`. It simplifies the creation of common chart types while maintaining flexibility and customization options.

## Features

- Simple, unified API for all chart types
- Extensive styling and configuration options
- Responsive and interactive charts
- Built-in animations
- Type-safe data models
- Customizable themes

Supported chart types:
- Line Charts (single and multi-line)
- Bar Charts (single and grouped)
- Pie Charts
- Radar Charts
- Scatter Charts (data point distribution)

## Getting Started

### Prerequisites
- Flutter SDK ≥3.32.0
- Dart SDK ≥3.8.0

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  apz_charts:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/plugins/charts/v1.0.0
```

## Usage

### Quick Start

```dart
import 'package:apz_charts/apz_charts.dart';

// Create a simple line chart
APZChart(
  type: ChartType.line,
  data: APZLineData(
    title: 'Monthly Sales',
    lines: [
      APZLine(
        name: 'Revenue',
        points: [
          APZLinePoint(x: 0, y: 100),
          APZLinePoint(x: 1, y: 150),
          APZLinePoint(x: 2, y: 200),
        ],
      ),
    ],
  ),
  config: LineChartConfig(
    showDots: true,
    showArea: true,
    curved: true,
  ),
)
```

### Detailed Examples

Check the `/example` folder for detailed examples of each chart type:
- `line_chart_example.dart` - Single and multi-line charts
- `bar_chart_example.dart` - Single and grouped bar charts
- `pie_chart_example.dart` - Pie charts with customization
- `radar_chart_example.dart` - Radar charts with multiple data points
- `scatter_chart_example.dart` - Scatter plots with multiple datasets

## Documentation

### Chart Types

#### Line Chart
- Single line charts with customizable styles
- Multi-line charts with different colors
- Area fill and curve options
- Custom tooltips and data points
- Grid line customization

```dart
APZChart(
  type: ChartType.line,                              // Specify the chart type (line, bar, pie, radar)
  data: APZLineData(                                 // Create line chart data
    title: 'Temperature Over Time',
    lines: [
      APZLine(                                       // Example line with label
        name: 'Max Temp',                            // Name of the line
        points: [                                    // Points with x, y coordinates and optional labels
          APZLinePoint(x: 0, y: 10, label: "Week 1") // Example point with label
        ],
        color: Colors.red,                           // Color of the line
      ),
      APZLine(
        name: 'Min Temp',
        points: [/* ... */],
        color: Colors.blue,
      ),
    ],
  ),
  config: LineChartConfig(                           // Configuration options for the line chart
    showDots: true,
    showArea: true,
    curved: true,
    showGridLines: true,
    chartBackgroundColor: Colors.grey.withOpacity(0.1),
  ),
)
```

#### Bar Chart
- Single bar charts with individual values
- Grouped bar charts for comparing categories
- Custom styling with border radius
- Background colors and spacing options
- Value labels and grid lines

```dart
APZChart(                                               
  type: ChartType.bar,                      // Specify the chart type (line, bar, pie, radar)
  data: APZBarData(                         // Create bar chart data
    title: 'Monthly Sales',
    groups: [
                                            // Single Bar Group
      APZBarGroup(                          // Group of bars for a specific category
        groupLabel: "Q1",                   // Label for the group
        items: [                                        
          APZBarItem(                       // Individual bar item
            value: 100,                     // Value of the bar
            label: "Product A",             // Label for the bar
            color: Colors.blue              // Color of the bar
          ),
        ],
      ),
                                            // Multiple Bar Broup Chart
      APZBarGroup(                          // Group of bars for a specific category
        groupLabel: "Q1",                   // Label for the group
        items: [                                        
          APZBarItem(                       // Individual bar item
            value: 100,                     // Value of the bar
            label: "Product A",             // Label for the bar
            color: Colors.blue              // Color of the bar
          ),
          APZBarItem(
            value: 150,
            label: "Product B",
            color: Colors.green,
          ),
        ],
      ),
    ],
  ),
  config: BarChartConfig(
    showValues: true,
    showGridLines: true,
    barWidth: 12,
    borderRadius: 4,
    groupSpacing: 0.2,
    barSpacing: 0.1,
  );
)
```

#### Pie Chart
- Basic pie chart creation
- Section spacing and colors
- Center space customization
- Value labels and percentages
- Interactive tooltips

```dart
APZChart(
  type: ChartType.pie,                   // Specify the chart type (line, bar, pie, radar)
  data: APZPieData(                      // Create pie chart data
    title: 'Revenue Distribution',
    sections: [
      APZPieSection(                     // Individual pie section
        value: 35,                       // Value of the section
        label: "Housing",                // Label for the section
        color: Colors.blue,              // Color of the section
      ),
      APZPieSection(
        value: 25,
        label: "Food",
        color: Colors.green,
      ),
    ],
  ),
  config: PieChartConfig(
    showValues: true,
    centerSpaceRadius: 40,
  );
)
```

#### Radar Chart
- Create multi-dimensional data visualization
- Customize grid appearance
- Add multiple data points
- Style radar areas and lines

```dart
APZChart(
  type: ChartType.radar,                            // Specify the chart type (line, bar, pie, radar)
  data: APZRadarData(                               // Create radar chart data
    title: 'Performance Metrics',
    features: ['Speed', 'Accuracy', 'Efficiency'],  // Features(Polygon Points) of the radar chart
    points: [                                       // Data points for the radar chart  
      APZRadarPoint(
        values: <double>[90, 70, 80, 60, 85, 75],   // Values corresponding to each feature
        label: "Developer A",                       // Label for the data point
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
    fillArea: true,
    gridOpacity: 0.2,
  );
)
```

#### Scatter Chart
- Data point distribution visualization
- Multiple datasets with different colors
- Customizable point sizes
- Interactive tooltips
- Grid lines and axis customization

```dart
APZChart(
  type: ChartType.scatter,                // Specify the chart type
  data: APZScatterData(                   // Create scatter chart data
    series: [
      APZScatterSeries(                   // Individual scatter series
        name: 'Dataset A',                // Name of the dataset
        points: [                         // Points in the dataset
          APZScatterPoint(               
            x: 2.5,                       // X coordinate
            y: 3.2,                       // Y coordinate
            size: 8,                      // Optional point size
          ),
        ],
        color: Colors.blue,               // Color for this dataset
      ),
    ],
  ),
  config: ScatterChartConfig(             // Configuration options
    showDots: true,
    dotSize: 8,
    minX: 0,
    maxX: 10,
    minY: 0,
    maxY: 10,
    showGridLines: true,
    gridLinesColor: Colors.grey.withOpacity(0.2),
    showTooltips: true,
    tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
    tooltipTextColor: Colors.white,
    legendTitleXAxis: 'X Axis',
    legendTitleYAxis: 'Y Axis',
  ),
)
```

## Configuration Options

### Common Options
All chart configurations extend BaseChartConfig and support:
- `title`: Chart title
- `showLegend`: Show/hide legend
- `legendTitleXAxis`: X-axis title
- `legendTitleYAxis`: Y-axis title
- `padding`: Chart padding
- `backgroundColor`: Chart background color

### Chart-Specific Features

#### Line Chart
- Multiple lines with different colors
- Area fill with customizable opacity
- Curved or straight lines
- Customizable dots
- Grid lines configuration
- Custom tooltips

#### Bar Chart
- Customizable bar width and spacing
- Border radius for bars
- Background color for bars
- Group spacing for grouped bars
- Value labels

#### Pie Chart
- Section spacing
- Center space radius
- Custom section colors
- Value labels
- Start degree offset
- Interactive tooltips

#### Radar Chart
- Multiple data points
- Fill area option
- Custom grid opacity
- Adjustable tick count
- Custom tick text size

#### Scatter Chart
- Point size customization
- Multiple dataset support
- Grid lines customization
- Axis range control
- Tooltip customization
- Custom colors for points and datasets

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Testing

Run tests with:
```bash
flutter test
```

## License

This project is licensed under the MIT License - see the LICENSE file for details
