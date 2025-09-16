# APZ Charts Example

This example project demonstrates various ways to use the APZ Charts library in a Flutter application. Each example showcases different chart types and their customization options.

## Getting Started

1. Ensure you have Flutter installed and set up
2. Add this to your package's `pubspec.yaml` file:
  ```yaml
  dependencies:
    apz_charts:
      git:
        url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
        ref: develop
        path: apz_core/plugins/charts/v1.0.0
  ```
3. Run `flutter pub get` in the example directory
4. Run `flutter run` to start the example app

## Examples Overview

### Line Charts (`line_chart_example.dart`)
Demonstrates how to create:
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
  config: LineChartConfig(/* ... */),               // Configuration options for the line chart
)
```

### Bar Charts (`bar_chart_example.dart`)
Shows two main bar chart types:
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
  config: BarChartConfig(                   // Configuration options for the bar chart
    type: BarChartType.grouped,
    barWidth: 12,
    borderRadius: 4,
    // ... other options
  ),
)
```

### Pie Charts (`pie_chart_example.dart`)
Demonstrates:
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
  config: PieChartConfig(               // Configuration options for the pie chart
    showValues: true,
    centerSpaceRadius: 40,
    sectionSpacing: 2,
  ),
)
```

### Radar Charts (`radar_chart_example.dart`)
Shows how to:
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
  config: RadarChartConfig(                         // Configuration options for the radar chart
    fillArea: true,
    gridOpacity: 0.2,
  ),
)
```


### Scatter Charts (`scatter_chart_example.dart`)
Demonstrates:
- Data point distribution visualization
- Multiple datasets with different colors
- Custom point sizes and colors
- Interactive tooltips and grid lines
- Axis customization with labels

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
    showGridLines: true,
    showTooltips: true,
    legendTitleXAxis: 'X Axis',
    legendTitleYAxis: 'Y Axis',
  ),
)
```

## Key Features Demonstrated

1. Chart Type Selection
   - How to choose and switch between chart types
   - Proper configuration for each type

2. Data Formatting
   - Structuring data for different chart types
   - Adding labels and values
   - Handling multiple data series

3. Styling and Customization
   - Color schemes
   - Spacing and layout
   - Borders and backgrounds
   - Labels and legends

4. Interaction Handling
   - Tooltips
   - Touch events
   - Animation control

## Project Structure

```
lib/
├── main.dart                    # Entry point and navigation
├── bar_chart_example.dart       # Bar chart demonstrations
├── line_chart_example.dart      # Line chart demonstrations
├── pie_chart_example.dart       # Pie chart demonstrations
├── radar_chart_example.dart     # Radar chart demonstrations
└── scatter_chart_example.dart   # Scatter chart demonstrations
```

## Running Specific Examples

Each example can be accessed through the main screen's navigation menu. The examples are organized by chart type, making it easy to find and test specific features.

## Customization Tips

1. Colors and Themes
   - Use your app's theme colors
   - Create consistent color schemes
   - Consider accessibility

2. Layout and Spacing
   - Adjust padding for different screen sizes
   - Use proper spacing between elements
   - Consider orientation changes

3. Data Presentation
   - Choose appropriate chart types for your data
   - Use clear labels and titles
   - Add helpful tooltips

## Common Usage Patterns

1. Data Visualization
   ```dart
   APZChart(
     type: chartType,
     data: chartData,
     config: chartConfig,
   )
   ```

2. Responsive Layout
   ```dart
   SizedBox(
     height: 400,
     child: APZChart(/* ... */),
   )
   ```

3. Interactive Elements
   ```dart
   APZChart(
     config: ChartConfig(
       showValues: true,
       showLegend: true,
       // ... other interactive options
     ),
   )
   ```

## Additional Resources

- Main APZ Charts documentation
- Flutter charting best practices
- Data visualization guidelines

## Contributing

Feel free to submit issues and enhancement requests for these examples.
