import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import './video_stream_page.dart';
import '../sidebar.dart';
import './ssh_terminal_page.dart';
import './chatbotpage.dart';
import './addtreepage.dart';
import './sensordashboardpage.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref("drone_rtd_acq");
  Set<Marker> markers = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  void fetchLocations() {
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        Set<Marker> newMarkers = {};
        data.forEach((key, value) {
          if (value["location"] != null) {
            double lat = value["location"]["latitude"];
            double lng = value["location"]["longitude"];
            newMarkers.add(
              Marker(
                markerId: MarkerId(key),
                position: LatLng(lat, lng),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Sidebar(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(0.0, 0.0),
              zoom: 5,
            ),
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
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

class TreeDetailPage extends StatelessWidget {
  final String treeCode;
  const TreeDetailPage({super.key, required this.treeCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Details of $treeCode")),
      body: Center(
        child: Text("All parameters of $treeCode will be shown here."),
      ),
    );
  }
}

class TerminalPage extends StatelessWidget {
  const TerminalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Terminal")),
      body: Center(child: Text("Terminal Page")),
    );
  }
}

class LiveCamPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Camera")),
      body: Center(child: Text("Live Cam Page")),
    );
  }
}

class ChatbotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatbot")),
      body: Center(child: Text("Chatbot Page")),
    );
  }
}

class AddTreePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Tree")),
      body: Center(child: Text("Add Tree Page")),
    );
  }
}
