import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:it_01/sidebar.dart';
import '../widgets/graph_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Map<String, List<FlSpot>> parameterData = {};

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
  }
  Future<void> _fetchDataFromFirestore() async {
    try {
      // Assuming a collection named 'sensor_data' with documents containing the data
      QuerySnapshot snapshot = await _firestore.collection('sensor_data').get();

      Map<String, List<FlSpot>> tempData = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data.forEach((key, value) {
          if (value is List<dynamic>) {
            tempData[key] = value.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble() + 1, entry.value.toDouble());
            }).toList();
          }
        });
      }

      setState(() {
        parameterData = tempData;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data History'),
        centerTitle: true,
      ),
      drawer: Sidebar(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: parameterData.entries.map((entry) {
          return GraphWidget(
            title: entry.key,
            dataPoints: entry.value,
            color: _getColorForParameter(entry.key),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForParameter(String parameter) {
    switch (parameter) {
      case "Temperature":
        return Colors.red;
      case "Humidity":
        return Colors.blue;
      case "Solar Radiation":
        return Colors.yellow;
      case "Anemometer":
        return Colors.green;
      case "Soil Temperature":
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
