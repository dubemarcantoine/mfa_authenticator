import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityConfig extends StatefulWidget {
  @override
  _SecurityConfigState createState() => _SecurityConfigState();
}

class _SecurityConfigState extends State<SecurityConfig> {
  final String IS_USING_AUTH_KEY = 'IS_USING_AUTH';

  SharedPreferences _preferences;
  bool _isUsingAuth = false;

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
          onChanged: (bool newValue) {
            setState(() {
              _isUsingAuth = newValue;
              _preferences.setBool(IS_USING_AUTH_KEY, _isUsingAuth);
            });
          },
        ),
      ),
    );
  }

  void _initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _isUsingAuth = _preferences.getBool(IS_USING_AUTH_KEY);
    });
  }
}