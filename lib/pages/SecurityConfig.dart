import 'package:authenticator/helpers/BiometricsHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityConfig extends StatefulWidget {
  static const String IS_USING_BIOMETRICS_AUTH_KEY = 'IS_USING_AUTH';

  @override
  _SecurityConfigState createState() => _SecurityConfigState();
}

class _SecurityConfigState extends State<SecurityConfig> {
  static const platform =
      const MethodChannel('io.github.dubemarcantoine/authenticator_mfa');
  BiometricsHelper biometricsHelper = BiometricsHelper();
  SharedPreferences _preferences;
  bool _isUsingBiometricsAuthentication = false;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: Text(
              'Enabling security will help keep your account codes secure. '
                  'A system prompt will ask you to give permission to enable '
                  'biometric authentication.',
              textScaleFactor: 1.05,
            ),
          ),
          SwitchListTile(
            value: _isUsingBiometricsAuthentication,
            title: Text('Biometric authentication'),
            onChanged: _onBiometricsPreferenceChange,
          ),
        ],
      ),
    );
  }

  ///  Initializes the preferences.
  ///  If no biometrics available on device, this preference will not be
  ///  able to be changed
  void _initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _isUsingBiometricsAuthentication =
          _preferences.getBool(SecurityConfig.IS_USING_BIOMETRICS_AUTH_KEY) ??
              false;
    });
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
