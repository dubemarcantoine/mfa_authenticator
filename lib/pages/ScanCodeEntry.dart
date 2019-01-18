import 'dart:core';

import 'package:flutter/material.dart';
import 'package:mfa_authenticator/pages/OtpList.dart';
import 'package:mfa_authenticator/model/OtpItem.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanCodeEntry extends StatefulWidget {
  @override
  _ScanCodeEntryState createState() => new _ScanCodeEntryState();
}

class _ScanCodeEntryState extends State<ScanCodeEntry> {
  bool validationDisabled = false;
  bool readyToExit = false;

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
                        _validateCode(code);
                      },
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  void _validateCode(String code) {
    if (!this.validationDisabled) {
      this.validationDisabled = true;
      Uri uri = Uri.dataFromString(code);
      if (!uri.queryParameters.containsKey('secret')) {
        this._showErrorDialog().then((v) {
          this.validationDisabled = false;
        });
      } else {
        if (!this.readyToExit) {
          this.readyToExit = true;
          OtpItem otpItem = new OtpItem(
            secret: uri.queryParameters['secret']?.toString(),
            issuer: uri.queryParameters['issuer']?.toString(),
            timeBased: uri.path.toLowerCase().contains('totp'),
          );
          key.currentState.addOtpItem(otpItem);
          Navigator.pop(context, true);
        }
        this.validationDisabled = false;
      }
    }
  }

  Future<void> _showErrorDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid code'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please scan a valid QR code'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
