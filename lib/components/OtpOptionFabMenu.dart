import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mfa_authenticator/pages/ManualEntry.dart';
import 'package:mfa_authenticator/pages/ScanCodeEntry.dart';

class OtpOptionFabMenu extends StatefulWidget {

  String title;

  OtpList(String title) {
    this.title = title;
  }

  @override
  _OtpOptionFabMenu createState() => _OtpOptionFabMenu();
}

class _OtpOptionFabMenu extends State<OtpOptionFabMenu> with TickerProviderStateMixin {
  /// The menu options that appear in the FAB
  List<MenuOption> fabMenuOptions = [];
  AnimationController fabAnimationController;

  @override
  void initState() {
    super.initState();
    this.fabMenuOptions = [
      MenuOption(Icons.edit, 'Manual entry', _manualEntry),
      MenuOption(Icons.camera_alt, 'Scan bar/QR code', _scanCodeEntry),
    ];

    fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              parent: fabAnimationController,
              curve: Interval(0.0, 1.0 - index / fabMenuOptions.length / 2.0,
                  curve: Curves.easeOut),
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
      }).toList()
        ..add(
          FloatingActionButton(
            heroTag: null,
            child: AnimatedBuilder(
              animation: fabAnimationController,
              builder: (BuildContext context, Widget child) {
                return Transform(
                  transform:
                  new Matrix4.rotationZ(fabAnimationController.value * 0.5 * pi),
                  alignment: FractionalOffset.center,
                  child:
                  Icon(fabAnimationController.isDismissed ? Icons.add : Icons.close),
                );
              },
            ),
            onPressed: fabMenuPressedHandler,
          ),
        ),
    );
  }

  void _manualEntry() {
    fabMenuPressedHandler();
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ManualEntry();
        },
      ),
    );
  }

  void _scanCodeEntry() {
    fabMenuPressedHandler();
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ScanCodeEntry();
        },
      ),
    );
  }

  void fabMenuPressedHandler() {
    if (fabAnimationController.isDismissed) {
      fabAnimationController.forward();
    } else {
      fabAnimationController.reverse();
    }
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