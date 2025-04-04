import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:it_01/firebase_options.dart';
import 'package:it_01/pages/donut_rtdb_page.dart';
// import 'pages/donut_chart_page.dart';
import 'pages/graph_page.dart';
import 'pages/video_stream_page.dart';
import 'pages/map_screen.dart';
import 'pages/diseasedetectionpage.dart';
import 'pages/map_screen1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen01(),
    );
  }
} // DiseaseDetectionPage(treeCode: "tree_code_001",feedsFor: "fertilizer_util",)

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Charts & Video'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DonutRtdbPage()),
                );
              },
              child: Text('Donut Charts'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GraphPage()),
                );
              },
              child: Text('Graphs'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideoStreamPage()),
                );
              },
              child: Text('Video Stream'),
            ),
          ],
        ),
      ),
    );
  }
}
