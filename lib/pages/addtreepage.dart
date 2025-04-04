import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import './qrcodepage.dart';

class AddTreePage01 extends StatefulWidget {
  @override
  _AddTreePageState createState() => _AddTreePageState();
}

class _AddTreePageState extends State<AddTreePage01> {
  final TextEditingController _treeNameController = TextEditingController();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("drone_rtd_acq");

  Future<void> _addTree() async {
    String treeName = _treeNameController.text.trim();
    if (treeName.isEmpty) return;

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      await dbRef.child(treeName).set({
        "location": {
          "latitude": position.latitude,
          "longitude": position.longitude,
        },
        "type":"tree",
        "for_ndvi_est":{
          "leaf_surface_temp":0,
          "timestamp_ds18":0,
        },
        "growth_monitor":{
          "altitude":0,
          "pressure":0,
          "timestamp_bmp":0,
        },
      });

      // Navigate to QR Code Page with tree name
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QRCodePage(treeName: treeName)),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Tree")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _treeNameController,
              decoration: InputDecoration(
                hintText: "Enter Tree Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTree,
              child: Text("Add Tree"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
