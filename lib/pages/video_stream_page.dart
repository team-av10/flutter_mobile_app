import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoStreamPage extends StatefulWidget {
  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Replace this URL with your Raspberry Pi's video stream URL
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          'http://192.168.1.102:5000/video_feed'),
    )
      ..initialize().then((_) {
        setState(() {}); // Update the UI once the video is initialized
      })
      ..setLooping(true) // Keep the video looping
      ..play(); // Start playing the video
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Stream'),
        centerTitle: true,
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(), // Show a loader while the video initializes
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:it_01/sidebar.dart';
// import 'donut_chart_page.dart';

// class VideoStreamPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Donut Charts Example'),
//         centerTitle: true,
//       ),
//       drawer: Sidebar(),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => DonutChartPage()),
//             );
//           },
//           child: Text('View Donut Charts'),
//         ),
//       ),
//     );
//   }
// }
