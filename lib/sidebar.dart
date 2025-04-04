import 'package:flutter/material.dart';
import 'package:it_01/pages/donut_chart_page.dart';
import 'package:it_01/pages/graph_page.dart';
import 'package:it_01/pages/video_stream_page.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'asserts/av10-logo.png',
                  height: 90,
                ),
                SizedBox(height: 10),
                Text(
                  'Konnichiwa Harappo🐾!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.pie_chart_outline),
            title: Text('Realtime Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DonutChartPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Data History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GraphPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.videocam),
            title: Text('Video Stream'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideoStreamPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
