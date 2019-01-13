import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mfa_authenticator/ManualEntry.dart';
import 'package:mfa_authenticator/OtpList.dart';
import 'package:mfa_authenticator/ScanCodeEntry.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authenticator',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.redAccent,
        primarySwatch: Colors.red,
        primaryColorDark: Colors.red,
        toggleableActiveColor: Colors.red,
      ),
      home: OtpList(title: 'Authenticator'),
    );
  }
}
