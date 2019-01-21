import 'package:flutter/material.dart';
import 'package:mfa_authenticator/main.dart';

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
            onPressed: () {
              appKey.currentState.tryAuthenticate();
            },
            child: Text('TRY AGAIN'),
          ),
        ],
      ),
    );
  }
}
