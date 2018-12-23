import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanCodeEntry extends StatefulWidget {
  @override
  _ScanCodeEntryState createState() => new _ScanCodeEntryState();
}

class _ScanCodeEntryState extends State<ScanCodeEntry> {
  String qr;
  bool camState = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Plugin example app'),
      ),
      body: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Expanded(
                child: camState
                    ? new Center(
                  child: new SizedBox(
                    width: 400.0,
                    height: 400.0,
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
                      child: new Container(
                        decoration: new BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.orange, width: 10.0, style: BorderStyle.solid),
                        ),
                      ),
                    ),
                  ),
                )
                    : new Center(child: new Text("Camera inactive"))),
            new Text("QRCODE: $qr"),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Text(
            "press me",
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            setState(() {
              camState = !camState;
            });
          }),
    );
  }
}
