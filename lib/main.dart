import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mfa_authenticator/OtpList.dart';
import 'package:mfa_authenticator/SecurityConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(Base());

class Base extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return App();
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  SharedPreferences _preferences;

  var _result = null;

  @override
  void initState() {
    authenticate().then((res) {
      setState(() {
        _result = res;
      });
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (_result == null || !_result) {
      return Container();
    }
    return MaterialApp(
      title: 'Authenticator',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.green,
        primarySwatch: Colors.green,
        primaryColorDark: Colors.green,
        toggleableActiveColor: Colors.green,
      ),
      home: OtpList(title: 'Authenticator'),
    );
  }

  Future<bool> authenticate() async {
    _preferences = await SharedPreferences.getInstance();
    bool result = _preferences.getBool(SecurityConfig.IS_USING_AUTH_KEY);
    if (!result) {
      return Future.value(true);
    } else {
      var localAuth = LocalAuthentication();
      List<BiometricType> availableBiometrics =
          await localAuth.getAvailableBiometrics();
      if (Platform.isIOS) {
        if (availableBiometrics.contains(BiometricType.face)) {
          return await localAuth.authenticateWithBiometrics(
              localizedReason: 'Please authenticate to view your codes');
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          // Touch ID.
        }
      }
    }
  }
}
