import 'dart:core';

import 'package:flutter/material.dart';
import 'package:mfa_authenticator/model/OtpItem.dart';
import 'package:mfa_authenticator/pages/OtpList.dart';
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
                  onError: (context, error) => Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                            child: Text(
                              'Could not open camera. '
                                  'Please make sure that the camer is active in your Settings app and try again.',
                              textScaleFactor: 1.05,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                            child: Text(
                              'If your device does not have a camera, please input the code manually.',
                              textScaleFactor: 1.05,
                            ),
                          ),
                        ],
                      ),
                  qrCodeCallback: (code) {
                    _validateCode(code);
                  },
                ),
              ),
            )),
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
            secret: uri.queryParameters['secret'],
            issuer: _getUriIssuer(uri),
            account: _getUriAccount(uri),
            digits: _getUriDigits(uri),
//            timeBased: uri.path.toLowerCase().contains('totp'),
          );
          otpListKey.currentState.addOtpItem(otpItem);
          Navigator.pop(context, true);
        }
        this.validationDisabled = false;
      }
    }
  }

  String _getUriIssuer(Uri uri) {
    String issuer = Uri.decodeFull(uri.queryParameters['issuer']);
    if (issuer != null) {
      return issuer;
    }
    return _getUriLabelPartAt(uri, 0);
  }

  String _getUriAccount(Uri uri) {
    return _getUriLabelPartAt(uri, 1);
  }

  String _getUriLabelPartAt(Uri uri, int index) {
    String label =
        Uri.decodeFull(uri.pathSegments.elementAt(uri.pathSegments.length - 1));
    List<String> parts = label.split(':');
    if (parts.length > index) {
      return parts.elementAt(index);
    }
    return '';
  }

  int _getUriDigits(Uri uri) {
    String strDigits = uri.queryParameters['digits'];
    if (strDigits != null) {
      return int.parse(strDigits);
    } else {
      return 6;
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
