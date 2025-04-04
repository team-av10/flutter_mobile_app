import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/donut_chart_widget.dart'; // Import your donut chart widget
import 'chatbotpage.dart'; // Replace with actual pages

class SensorDashboardPage extends StatefulWidget {
  final String treeCode;

  const SensorDashboardPage({super.key, required this.treeCode});

  @override
  _SensorDashboardPageState createState() => _SensorDashboardPageState();
}

class _SensorDashboardPageState extends State<SensorDashboardPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? sensorData;
  String? type;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DatabaseEvent event = await _databaseRef.child("drone_rtd_acq/${widget.treeCode}").once();
      if (event.snapshot.value != null) {
        Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          type = data["type"]; // Check if type is "tree" or "station"
          sensorData = data;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (type == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Sensor Dashboard - ${widget.treeCode}")),
      body: SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Center( // Center aligns all children
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // Aligns items in the center
      crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
      children: [
        if (type == "tree") ...[
          DonutChartWidget(
            title: "Leaf Surface Temp",
            value: sensorData?["for_ndvi_est"]["leaf_surface_temp"]?.toDouble() ?? 0,
            color: Colors.green,
            unit: "°C",
            mvalue: 100,
          ),
          DonutChartWidget(
            title: "Altitude",
            value: sensorData?["growth_monitor"]["altitude"]?.toDouble() ?? 0,
            color: Colors.blue,
            unit: "m",
            mvalue: 500,
          ),
          DonutChartWidget(
            title: "Pressure",
            value: sensorData?["growth_monitor"]["pressure"]?.toDouble() ?? 0,
            color: Colors.orange,
            unit: "hPa",
            mvalue: 110000,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotPage01()));
            },
            child: Text("Navigate to Page 1"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotPage01()));
            },
            child: Text("Navigate to Page 2"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotPage01()));
            },
            child: Text("Navigate to Page 3"),
          ),
        ] else if (type == "station") ...[
          DonutChartWidget(
            title: "Altitude",
            value: sensorData?["altitude"]?.toDouble() ?? 0,
            color: Colors.blue,
            unit: "m",
            mvalue: 500,
          ),
          DonutChartWidget(
            title: "Atmospheric Pressure",
            value: sensorData?["atmosPressure"]?.toDouble() ?? 0,
            color: Colors.orange,
            unit: "hPa",
            mvalue: 110000,
          ),
          DonutChartWidget(
            title: "Environment Temp",
            value: sensorData?["environmentTemp"]?.toDouble() ?? 0,
            color: Colors.red,
            unit: "°C",
            mvalue: 50,
          ),
          DonutChartWidget(
            title: "Flow Rate",
            value: sensorData?["flowRate"]?.toDouble() ?? 0,
            color: Colors.purple,
            unit: "L/s",
            mvalue: 100,
          ),
          DonutChartWidget(
            title: "Humidity",
            value: sensorData?["humidity"]?.toDouble() ?? 0,
            color: Colors.cyan,
            unit: "%",
            mvalue: 100,
          ),
          DonutChartWidget(
            title: "Soil Moisture",
            value: sensorData?["soilMoist"]?.toDouble() ?? 0,
            color: Colors.brown,
            unit: "%",
            mvalue: 100,
          ),
          DonutChartWidget(
            title: "Soil Temp",
            value: sensorData?["soilTemp"]?.toDouble() ?? 0,
            color: Colors.green,
            unit: "°C",
            mvalue: 50,
          ),
        ] else ...[
          Center(child: Text("Invalid treeCode or missing type data")),
        ],
      ],
    ),
  ),
),
    );
  }
}
