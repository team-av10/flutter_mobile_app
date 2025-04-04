import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

class QRCodePage extends StatefulWidget {
  final String treeName;

  QRCodePage({required this.treeName});

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  GlobalKey _globalKey = GlobalKey();

  Future<void> _captureAndSaveQRCode() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/qr_code.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("QR Code saved to $filePath")),
      );
    } catch (e) {
      print("Error capturing QR code: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.treeName} QR Code")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Scan to View ${widget.treeName} Details", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            RepaintBoundary(
              key: _globalKey,
              child: QrImageView(
                data: widget.treeName,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _captureAndSaveQRCode,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Save QR Code"),
            ),
          ],
        ),
      ),
    );
  }
}
