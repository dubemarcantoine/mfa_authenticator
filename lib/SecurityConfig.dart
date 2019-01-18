import 'package:flutter/material.dart';
import 'package:mfa_authenticator/BiometricsHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityConfig extends StatefulWidget {
  static const String IS_USING_BIOMETRICS_AUTH_KEY = 'IS_USING_AUTH';

  @override
  _SecurityConfigState createState() => _SecurityConfigState();
}

class _SecurityConfigState extends State<SecurityConfig> {
  BiometricsHelper biometricsHelper = BiometricsHelper();
  SharedPreferences _preferences;
  bool _isUsingBiometricsAuthentication = false;
  Function _onBiometricsPreferenceChangeFunction;

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
          value: _isUsingBiometricsAuthentication,
          title: Text('Enable authentication'),
          onChanged: _onBiometricsPreferenceChangeFunction,
        ),
      ),
    );
  }

  ///  Initializes the preferences.
  ///  If no biometrics available on device, this preference will not be
  ///  able to be changed
  void _initPreferences() async {
    if (await biometricsHelper.hasBiometrics()) {
      _onBiometricsPreferenceChangeFunction = _onBiometricsPreferenceChange;
      _preferences = await SharedPreferences.getInstance();
      setState(() {
        _isUsingBiometricsAuthentication =
            _preferences.getBool(SecurityConfig.IS_USING_BIOMETRICS_AUTH_KEY) ??
                false;
      });
    }
  }

  void _onBiometricsPreferenceChange(bool newValue) async {
    bool authResult = await biometricsHelper.localAuthentication
        .authenticateWithBiometrics(
            localizedReason: 'Please authenticate to procede');
    if (authResult) {
      setState(() {
        _isUsingBiometricsAuthentication = newValue;
      });
      _preferences.setBool(SecurityConfig.IS_USING_BIOMETRICS_AUTH_KEY,
          _isUsingBiometricsAuthentication);
    }
  }
}
