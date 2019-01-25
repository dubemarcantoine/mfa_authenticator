import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mfa_authenticator/main.dart';

class LoginError extends StatelessWidget {
  static const platform =
      const MethodChannel('io.github.dubemarcantoine/authenticator_mfa');

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
                  'Please make sure that the biometrics are active in your Settings app and try again.',
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
    platform.invokeMethod('openAppPreferences');
  }
}
