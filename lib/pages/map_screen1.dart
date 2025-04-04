import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import './video_stream_page.dart';
import '../sidebar.dart';
import './ssh_terminal_page.dart';
import './chatbotpage.dart';
import './addtreepage.dart';
import './sensordashboardpage.dart';
import 'dart:async';

class MapScreen01 extends StatefulWidget {
  const MapScreen01({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen01> {
  GoogleMapController? mapController;
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref("drone_rtd_acq");
  Set<Marker> markers = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();


  // Custom marker variables
  late BitmapDescriptor stationMarker;
  late BitmapDescriptor treeMarker;

  @override
  void initState() {
    super.initState();
    loadCustomMarkers().then((_) {
      print("Markers loaded successfully!");
      fetchLocations();
    }).catchError((error) {
      print("Error loading markers: $error");
    });
  }

  // ✅ Load custom markers using BitmapDescriptor.asset()
  Future<void> loadCustomMarkers() async {
    try {
      stationMarker =
          await BitmapDescriptor.asset(
      const ImageConfiguration(devicePixelRatio: 2.0),
      'asserts/marker2.webp',
      width: 70,  // Optional: Adjust width
      height: 70, // Optional: Adjust height
      imagePixelRatio: 2.0, // Improve resolution
      );
      // treeMarker = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      treeMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(devicePixelRatio: 2.0),
      'asserts/marker1.webp',
      width: 70,  // Optional: Adjust width
      height: 70, // Optional: Adjust height
      imagePixelRatio: 2.0, // Improve resolution


    );

      setState(() {}); // Refresh UI
      print("Custom markers loaded successfully!");
    } catch (e) {
      print("Error loading custom markers: $e");
    }
  }

  // ✅ Fetch locations from Firebase and assign markers based on type
  void fetchLocations() {
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        Set<Marker> newMarkers = {};
        data.forEach((key, value) {
          if (value["location"] != null && value["type"] != null) {
            double lat = value["location"]["latitude"];
            double lng = value["location"]["longitude"];
            String type = value["type"];

            // Choose correct marker based on type
            BitmapDescriptor selectedMarker =
                (type == "station") ? stationMarker : treeMarker;

            newMarkers.add(
              Marker(
                markerId: MarkerId(key),
                position: LatLng(lat, lng),
                icon: selectedMarker, // ✅ Custom marker here
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SensorDashboardPage(treeCode: key),
                    ),
                  );
                },
              ),
            );
          }
        });
        setState(() {
          markers = newMarkers;
        });
      }
    });
  }

  final String _mapStyle = ''' 
  [
    {
      "featureType": "all",
      "elementType": "geometry",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text",
      "stylers": [
        { "visibility": "on" }
      ]
    },
    {
      "featureType": "poi.business",
      "elementType": "labels.text",
      "stylers": [
        { "visibility": "on" }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels",
      "stylers": [
        { "visibility": "off" }
      ]
    }
  ]
  ''';


  void _onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(_mapStyle);
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Sidebar(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(10.9437839, 76.9486424),
              zoom: 15,
            ),
            mapType: MapType.satellite,
            myLocationEnabled: true,
            compassEnabled: true,
            markers: markers,
            style: _mapStyle,
            onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Icon(Icons.menu, size: 18),
              mini: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          Positioned(
            top: 40,
            left: MediaQuery.of(context).size.width / 2 - 20,
            child: Image.asset('asserts/av10-logo.png', height: 50, width: 50),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavButton(Icons.terminal, SshTerminalPage()),
                SizedBox(width: 10),
                _buildNavButton(Icons.videocam, VideoStreamPage()),
                SizedBox(width: 10),
                _buildNavButton(Icons.chat, ChatbotPage01()),
                SizedBox(width: 10),
                _buildNavButton(Icons.add_circle, AddTreePage01()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, Widget targetPage) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      mini: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Icon(icon, size: 18),
    );
  }
}


