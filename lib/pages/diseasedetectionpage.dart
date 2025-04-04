import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class DiseaseDetectionPage extends StatefulWidget {
  final String treeCode; // Accept treeCode as a parameter
  final String feedsFor;
  DiseaseDetectionPage({required this.treeCode, required this.feedsFor});

  @override
  _DiseaseDetectionPageState createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends State<DiseaseDetectionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchDiseaseData() async {
    List<Map<String, dynamic>> imageList = [];

    try {
      QuerySnapshot imagesSnapshot = await _firestore
          .collection("drone_dat_acq")
          .doc(widget.treeCode) // Use treeCode from widget
          .collection(widget.feedsFor)
          .get();

      for (var doc in imagesSnapshot.docs) {
        String imagePath = doc.id; // Example: latest_image_001.jpg
        var data = doc.data() as Map<String, dynamic>?; // Convert to Map safely

        if (data == null ||
            !data.containsKey("image_data") ||
            !data.containsKey("prediction")) {
          print("Skipping $imagePath: Missing required fields");
          continue;
        }

        String base64Image = data["image_data"]; // Base64 string
        String prediction = data["prediction"]; // Prediction result

        Uint8List? imageBytes;
        try {
          imageBytes = base64Decode(base64Image);
        } catch (e) {
          imageBytes = null;
        }

        imageList.add({
          "image": imageBytes,
          "prediction": prediction,
          "name": imagePath,
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    return imageList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Disease Detection - ${widget.treeCode}")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDiseaseData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No disease data found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var imageData = snapshot.data![index];

              return Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Column(
                  children: [
                    imageData["image"] != null
                        ? Image.memory(imageData["image"],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover)
                        : Container(
                            height: 200,
                            color: Colors.grey,
                            child: Icon(Icons.broken_image, size: 50)),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Prediction: ${imageData["prediction"]}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "File: ${imageData["name"]}",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
