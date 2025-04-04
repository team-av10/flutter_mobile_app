import 'package:flutter/material.dart';
import 'package:it_01/sidebar.dart';
import '../widgets/donut_chart_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DonutRtdbPage extends StatefulWidget {
  const DonutRtdbPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DonutRtdbPageState createState() => _DonutRtdbPageState();
}

class _DonutRtdbPageState extends State<DonutRtdbPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("renesas-r4");
  Map<String, double> _chartData = {};
  Map<String, double> _maxData = {};
  LatLng? _currentLocation;
  String _markerLabel = ''; // To store the label text

  @override
  void initState() {
    super.initState();
    _fetchChartData();
    _fetchLocation();
  }

  // Fetch chart data from Firebase
  Future<void> _fetchChartData() async {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _chartData = {
            "Temperature": data["temp"]?.toDouble() ?? 0,
            "Humidity": data["humid"]?.toDouble() ?? 0,
            "Solar Radiation": data["solar-rad"]?.toDouble() ?? 0,
            "Anemometer": data["windspeed"]?.toDouble() ?? 0,
            "Soil Temperature": data["soil-temp"]?.toDouble() ?? 0,
          };
          _maxData = {
            "Temperature": data["m-temp"]?.toDouble() ?? 0,
            "Humidity": 100,
            "Solar Radiation": data["m-solar-rad"]?.toDouble() ?? 0,
            "Anemometer": data["m-windspeed"]?.toDouble() ?? 0,
            "Soil Temperature": data["m-soil-temp"]?.toDouble() ?? 0,
          };
        });
      }
    });
  }

  // Fetch location data from Firebase
  Future<void> _fetchLocation() async {
    _dbRef.child("location").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          double latitude = data["latitude"]?.toDouble() ?? 0.0;
          double longitude = data["longitude"]?.toDouble() ?? 0.0;
          _currentLocation = LatLng(latitude, longitude);
        });
      }
    });
  }

  // To show the label on marker click
  void _onMarkerTapped(LatLng position) {
    setState(() {
      _markerLabel = 'Lt: ${position.latitude}, Lng: ${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realtime Data'),
        centerTitle: true,
      ),
      drawer: Sidebar(),
      body: Column(
        children: [
          // Rounded container with Google Map inside
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 130, // Height of the map
                child: _currentLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentLocation!,
                          zoom: 15.0,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('currentLocation'),
                            position: _currentLocation!,
                            onTap: () => _onMarkerTapped(_currentLocation!),
                          ),
                        },
                      ),
              ),
            ),
          ),
          // Label showing the marker coordinates
          if (_markerLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Current Location 📍 $_markerLabel',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ),
          // Chart data list
          Expanded(
            child: _chartData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: _chartData.keys.map((key) {
                      final value = _chartData[key] ?? 0;
                      final maxValue = _maxData[key] ?? 0;

                      return DonutChartWidget(
                        title: key,
                        value: value,
                        color: _getColorForParameter(key),
                        unit: _getUnitForParameter(key),
                        mvalue: maxValue,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // Get color for each parameter
  Color _getColorForParameter(String parameter) {
    switch (parameter) {
      case "Temperature":
        return const Color.fromARGB(255, 166, 57, 35);
      case "Humidity":
        return Colors.blue;
      case "Solar Radiation":
        return Colors.orange;
      case "Anemometer":
        return Colors.green;
      case "Soil Temperature":
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  // Get unit for each parameter
  String _getUnitForParameter(String parameter) {
    switch (parameter) {
      case "Temperature":
      case "Soil Temperature":
        return '°C';
      case "Humidity":
        return '%';
      case "Solar Radiation":
        return 'W/m²';
      case "Anemometer":
        return 'm/s';
      default:
        return ' ';
    }
  }
}
