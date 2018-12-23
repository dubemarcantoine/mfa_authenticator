import 'package:flutter/material.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';

class ScanCodeEntry extends StatefulWidget {
  @override
  _ScanCodeEntryState createState() => new _ScanCodeEntryState();
}

class _ScanCodeEntryState extends State<ScanCodeEntry> {
  QRReaderController controller;

  @override
  void initState() {
    super.initState();
    this._initScanner();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return new Container();
    }
    return new AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: new QRReaderPreview(controller));
  }

  void _initScanner() async {
    List<CameraDescription> cameras = await availableCameras();
    controller = new QRReaderController(cameras[0], ResolutionPreset.medium, [CodeFormat.qr], (dynamic value){
      print(value); // the result!
      // ... do something
      // wait 3 seconds then start scanning again.
      new Future.delayed(const Duration(seconds: 0), controller.startScanning);
    });
  }
}
