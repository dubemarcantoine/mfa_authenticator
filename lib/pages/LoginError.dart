import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mfa_authenticator/main.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Error'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: Text(
              'Error when authenticating. '
                  'Please make sure biometrics are active in your settings and try again.',
              textScaleFactor: 1.05,
            ),
          ),
          RaisedButton(
            onPressed: _goToSettings,
            child: Text('CHECK APP PERMISSIONS'),
          ),
          RaisedButton(
            onPressed: () {
              appKey.currentState.tryAuthenticate();
            },
            child: Text('LOGIN'),
          ),
        ],
      ),
    );
  }

  void _goToSettings() async {
    String url;
    if (Platform.isIOS) {
      url = 'App-prefs:root?path=Authenticator%20MFA';
    }
    if (await canLaunch(url)) {
      print('launch');
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
