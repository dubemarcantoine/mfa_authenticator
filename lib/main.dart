import 'package:flutter/material.dart';
import 'package:mfa_authenticator/ManualEntry.dart';
import 'package:mfa_authenticator/OtpList.dart';
import 'dart:math';

import 'package:mfa_authenticator/data/OtpItemDataMapper.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /// The menu options that appear in the FAB
  List<MenuOption> fabMenuOptions = [];
  AnimationController _controller;

  @override
  void initState() {
    this.fabMenuOptions = [
      MenuOption(Icons.edit, 'Manual entry', _manualEntry),
      MenuOption(Icons.camera_alt, 'Scan bar/QR code', _scanCodeEntry),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: OtpList(),
      floatingActionButton: _buildFab(),
    );
  }

  void _manualEntry() {
    Navigator.of(context).push(
        new MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return ManualEntry();
            },
        ),
    );
  }

  void _scanCodeEntry() {
    print('scan');
  }

  void fabMenuPressedHandler() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(fabMenuOptions.length, (int index) {
        MenuOption menuOption = fabMenuOptions[index];
        Widget child = Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(
                  0.0,
                  1.0 - index / fabMenuOptions.length / 2.0,
                  curve: Curves.easeOut
              ),
            ),
            child: FloatingActionButton(
              heroTag: null,
              mini: true,
              tooltip: menuOption.getDescription,
              child: Icon(menuOption.getIconData),
              onPressed: () {
                menuOption.getFunction();
                fabMenuPressedHandler();
              },
            ),
          ),
        );
        return child;
      }).toList()..add(
        FloatingActionButton(
          heroTag: null,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child) {
              return Transform(
                transform: new Matrix4.rotationZ(_controller.value * 0.5 * pi),
                alignment: FractionalOffset.center,
                child: Icon(_controller.isDismissed ? Icons.add : Icons.close),
              );
            },
          ),
          onPressed: fabMenuPressedHandler,
        ),
      ),
    );
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