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
      home: HomePage(title: 'Authenticator'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return OtpList(widget.title);
  }
}

class MenuOption {
  final IconData iconData;
  final String description;
  final Function function;

  MenuOption(this.iconData, this.description, this.function);

  IconData get getIconData {
    return this.iconData;
  }

  String get getDescription {
    return this.description;
  }

  Function get getFunction {
    return this.function;
  }
}
