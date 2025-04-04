import 'package:flutter/material.dart';
import 'package:it_01/sidebar.dart';
import '../widgets/donut_chart_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DonutChartPage extends StatefulWidget {
  const DonutChartPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DonutChartPageState createState() => _DonutChartPageState();
}

class _DonutChartPageState extends State<DonutChartPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("renesas-r4");
  Map<String, double> _chartData = {};
  Map<String, double> _maxData = {};
  LatLng? _currentLocation;
  String _markerLabel = '';
  // final LatLng _testLocation = LatLng(10.7632, 78.8164);

  @override
  void initState() {
    super.initState();
    _fetchChartData();
    _fetchLocation();
  }

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

  void _onMarkerTapped(LatLng position) {
    setState(() {
      _markerLabel = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height:300,
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
              )
            ),
          if (_markerLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Marker Position: $_markerLabel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _chartData.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: _chartData.keys.map((key) {
                        final value =
                            _chartData[key] ?? 0; // Value from _chartData
                        final maxValue = _maxData[key] ??
                            0; // Corresponding value from _maxData

                        return DonutChartWidget(
                          title: key,
                          value: value,
                          color: _getColorForParameter(key),
                          unit: _getUnitForParameter(key),
                          mvalue:
                              maxValue, // Pass the max value for this parameter
                        );
                      }).toList(),
                    ),
            ),
          ],
        ));
  }

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
