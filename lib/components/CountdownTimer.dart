import 'dart:async';
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:mfa_authenticator/helpers/TimeHelper.dart';

class CountdownTimer extends StatefulWidget {
  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController controller;

  String get timerString {
    if (controller.duration != null) {
      Duration duration = controller.duration * controller.value;
      return duration.inSeconds.toString();
    } else {
      return '0';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.suspending:
        break;
      case AppLifecycleState.resumed:
        _initInitialCountdown();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: 0,
        top: 0,
        right: 5,
        bottom: 0,
      ),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: FractionalOffset.center,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (BuildContext context, Widget child) {
                            return new CustomPaint(
                              painter: TimerPainter(
                                animation: controller,
                                backgroundColor: Colors.white,
                                color: themeData.indicatorColor,
                              ),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: FractionalOffset.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            AnimatedBuilder(
                              animation: controller,
                              builder: (BuildContext context, Widget child) {
                                return new Text(
                                  timerString,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initInitialCountdown() {
    final int secondsUntilNextRefresh = TimeHelper.getSecondsUntilNextRefresh();
    _startCountdown(secondsUntilNextRefresh);
    CancelableOperation.fromFuture(Future.delayed(Duration(seconds: secondsUntilNextRefresh), () => _initCountdownRefreshTimer()));
  }

  void _initCountdownRefreshTimer() {
    _startCountdown(30);
    Timer.periodic(Duration(seconds: 30), (Timer t) => this._startCountdown(30));
  }

  void _startCountdown(int secondsUntilNextRefresh) {
    controller.duration = Duration(seconds: secondsUntilNextRefresh);
    controller.reverse(from: 1.0);
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
