import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChartWidget extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final String unit;
  final double mvalue;

  const DonutChartWidget({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.unit,
    required this.mvalue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              width: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: color,
                      value: value,
                      title: '${value.toStringAsFixed(1)}$unit',
                      radius: 60,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.grey[300],
                      value: mvalue - value,
                      title: '',
                    ),
                  ],
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
