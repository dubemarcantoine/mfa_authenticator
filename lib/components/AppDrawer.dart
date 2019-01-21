import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mfa_authenticator/pages/SecurityConfig.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  static const platform =
      const MethodChannel('dubemarcantoine.github.io/authenticator_mfa');

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Security'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                new MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return SecurityConfig();
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('App Preferences'),
            onTap: () {
              platform.invokeMethod('openAppPreferences');
            },
          ),
        ],
      ),
    );
  }
}
