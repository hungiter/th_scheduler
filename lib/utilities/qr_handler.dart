import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;
import 'dart:io';

class QrCodeWidget extends StatefulWidget {
  final String data;

  const QrCodeWidget({Key? key, required this.data}) : super(key: key);

  @override
  _QrCodeWidgetState createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends State<QrCodeWidget> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _captureAndSave() async {
    try {
      // Capture the widget as an image
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get the directory to save the image
      final directory = (await getApplicationDocumentsDirectory()).path;
      final filePath =
          '$directory/${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Save the image to the gallery
      final result = await ImageGallerySaver.saveFile(filePath);
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          key: _globalKey,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(12.0), // Rounded corners
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // QR Code
                QrImageView(
                  data: widget.data,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                const SizedBox(height: 16.0),

                // Text below the QR code
                const Text(
                  'S C A N   H E R E',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _captureAndSave,
          child: Text('Save to Gallery'),
        ),
      ],
    );
  }
}

class ScanQRCode extends StatefulWidget {
  @override
  _ScanQRCodeState createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  String scanResult = "Not Scanned";

  Future<void> scanQRCode() async {
    var result = await BarcodeScanner.scan();
    setState(() {
      scanResult = result.rawContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('S C A N   R E S U L T \n $scanResult',
              textAlign: TextAlign.center),
          ElevatedButton(
            onPressed: scanQRCode,
            child: const Text('S C A N   Q R   C O D E'),
          ),
        ],
      ),
    );
  }
}
