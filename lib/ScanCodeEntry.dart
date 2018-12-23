import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanCodeEntry extends StatefulWidget {
  @override
  _ScanCodeEntryState createState() => new _ScanCodeEntryState();
}

class _ScanCodeEntryState extends State<ScanCodeEntry> {
  String qr;
  bool camState = true;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Scan QR code'),
      ),
      body: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Expanded(
                child: new Center(
                  child: new SizedBox(
                    child: new QrCamera(
                      onError: (context, error) => Text(
                        error.toString(),
                        style: TextStyle(color: Colors.red),
                      ),
                      qrCodeCallback: (code) {
                        setState(() {
                          qr = code;
                        });
                      },
                    ),
                  ),
                )
            ),
            new Text("QRCODE: $qr"),
          ],
        ),
      ),
    );
  }
}
