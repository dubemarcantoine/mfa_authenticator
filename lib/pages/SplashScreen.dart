import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        color: Color.fromRGBO(46, 46, 46, 1.0),
      ),
      child: Center(
        child: new Container(
          width: 256.0,
          height: 256.0,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/logo.png'),
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
      )
    );
  }
}
