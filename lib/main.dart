import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mfa_authenticator/BiometricsHelper.dart';
import 'package:mfa_authenticator/LoginError.dart';
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
  BiometricsHelper _biometricsHelper = BiometricsHelper();
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
    Widget homeWidget;
    if (_result == null) {
      homeWidget = Container();
    } else if (!_result) {
      homeWidget = LoginError();
    } else {
      homeWidget = OtpList(title: 'Authenticator');
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
      home: homeWidget,
    );
  }

  Future<bool> authenticate() async {
    _preferences = await SharedPreferences.getInstance();
    bool shouldAuthenticate =
        _preferences.getBool(SecurityConfig.IS_USING_BIOMETRICS_AUTH_KEY) ??
            false;
    if (!shouldAuthenticate) {
      return Future.value(true);
    } else {
      if (await _biometricsHelper.hasBiometrics()) {
        return await _biometricsHelper.localAuthentication
            .authenticateWithBiometrics(
                localizedReason: 'Please authenticate to view your codes');
      }
      // If user activated their authentication, but that there are no
      // biometric sensors available at the moment
      return Future.value(false);
    }
  }
}
