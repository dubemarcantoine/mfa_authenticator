import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityConfig extends StatefulWidget {
  static const String IS_USING_AUTH_KEY = 'IS_USING_AUTH';

  @override
  _SecurityConfigState createState() => _SecurityConfigState();
}

class _SecurityConfigState extends State<SecurityConfig> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  SharedPreferences _preferences;
  bool _isUsingAuth = false;
  Function _func = null;

  void initState() {
    _initPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Config'),
      ),
      body: Center(
        child: SwitchListTile(
          value: _isUsingAuth,
          title: Text('Enable authentication'),
          onChanged: _func,
        ),
      ),
    );
  }

  void _initPreferences() async {
    await _checkBiometrics();
    if (_canCheckBiometrics) {
      await _getAvailableBiometrics();
    }
    if (_availableBiometrics.length > 0) {
      _func = (bool newValue) {
        setState(() {
          _isUsingAuth = newValue;
          _preferences.setBool(
              SecurityConfig.IS_USING_AUTH_KEY, _isUsingAuth);
        });
      };
      _preferences = await SharedPreferences.getInstance();
      setState(() {
        _isUsingAuth =
            _preferences.getBool(SecurityConfig.IS_USING_AUTH_KEY) ?? false;
      });
    }
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on Exception catch (e) {
      print(e);
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    } on Exception catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }
}
