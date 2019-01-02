import 'dart:async';
import 'dart:math';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mfa_authenticator/ManualEntry.dart';
import 'package:mfa_authenticator/ScanCodeEntry.dart';
import 'package:mfa_authenticator/main.dart';
import 'package:otp/otp.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:mfa_authenticator/data/OtpItemDataMapper.dart';

final key = new GlobalKey<_OtpListState>();

class OtpList extends StatefulWidget {

  String title;

  OtpList(String title) {
    this.title = title;
  }

  @override
  _OtpListState createState() => _OtpListState();
}

class _OtpListState extends State<OtpList> with WidgetsBindingObserver, TickerProviderStateMixin {
  /// The menu options that appear in the FAB
  List<MenuOption> fabMenuOptions = [];
  AnimationController _controller;
  List<OtpItem> otpItems = [];
  CancelableOperation initialCountdown;
  Timer refreshTimer;

  int timeUntilRefresh = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(state.toString());
    switch (state) {
      case AppLifecycleState.inactive:
        this.initialCountdown?.cancel();
        this.refreshTimer?.cancel();
        break;
      case AppLifecycleState.paused:
        this.initialCountdown?.cancel();
        this.refreshTimer?.cancel();
        break;
      case AppLifecycleState.suspending:
        this.initialCountdown?.cancel();
        this.refreshTimer?.cancel();
        break;
      case AppLifecycleState.resumed:
        this._startInitialCountdown();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Text('30'), // TODO: See countdown here => https://stackoverflow.com/questions/44302588/flutter-create-a-countdown-widget
        ]
      ),
      body: FutureBuilder<List<OtpItem>>(
          future: OtpItemDataMapper.getOtpItems(),
          builder: (BuildContext context, AsyncSnapshot<List<OtpItem>> snapshot) {
            if (snapshot.hasData) {
              this.otpItems = snapshot.data;
              this.generateCodes();
            }
            return buildList();
          }
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget buildList() {
    return ListView.builder(
        itemCount: this.otpItems.length,
        itemBuilder: (context, index) {
          final item = this.otpItems[index];
          return Column(
            children: <Widget>[
              new Slidable(
                delegate: new SlidableDrawerDelegate(),
                child: ListTile(
                  title: Text(item.otpCode),
                  subtitle: Text(item.issuer),
                  onTap: () {
                    Clipboard.setData(new ClipboardData(text: item.otpCode));
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Copied code!'),
                    ));
                  },
                ),
                secondaryActions: <Widget>[
                  new IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () => _onDeleteTap(item),
                  ),
                ],
              ),
              new Divider(
                height: 0.0,
                color: Colors.grey
              ),
            ],
          );
        });
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
              animation: _controller,
              builder: (BuildContext context, Widget child) {
                return Transform(
                  transform:
                  new Matrix4.rotationZ(_controller.value * 0.5 * pi),
                  alignment: FractionalOffset.center,
                  child:
                  Icon(_controller.isDismissed ? Icons.add : Icons.close),
                );
              },
            ),
            onPressed: fabMenuPressedHandler,
          ),
        ),
    );
  }

  void addOtpItem(OtpItem otpItem) async {
    otpItem.id = await OtpItemDataMapper.newOtpItem(otpItem);
    setState(() {
      generateCode(otpItem);
      this.otpItems.add(otpItem);
    });

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Code added successfully!'),
    ));
  }

  void generateCodes() {
    this.otpItems.forEach((otpItem) => generateCode(otpItem));
  }

  void generateCode(OtpItem otpItem) {
    otpItem.otpCode = "${OTP.generateTOTPCode(otpItem.secret, DateTime.now().millisecondsSinceEpoch)}"
        .padLeft(6, '0');
  }

  void _startInitialCountdown() {
    if (DateTime.now().second <= 30) {
      this.timeUntilRefresh = (DateTime.now().second - 30).abs();
    } else {
      this.timeUntilRefresh = (DateTime.now().second - 60).abs();
    }
    this._setOtpCodesFromSecrets();
    print("Time until next refresh ${this.timeUntilRefresh}");
    this.initialCountdown = CancelableOperation.fromFuture(Future.delayed(
        Duration(seconds: this.timeUntilRefresh), () => _startTimer()));
  }

  void _startTimer() {
    this.timeUntilRefresh = 30;
    print("Time until next refresh ${this.timeUntilRefresh}");
    this.refreshTimer = Timer.periodic(
        Duration(seconds: this.timeUntilRefresh), (Timer t) => this._setOtpCodesFromSecrets());
  }

  void _setOtpCodesFromSecrets() {
    print("Refreshing... Next in 30 secs");
    setState(() {
      this.generateCodes();
    });
  }

  void _onDeleteTap(OtpItem otpItem) async {
    final bool userResponse = await _deleteConfirmationDialog();
    if (userResponse) {
      await OtpItemDataMapper.delete(otpItem.id);
      setState(() {
        this.otpItems.removeWhere((itemInList) => itemInList.id == otpItem.id);
      });
    }
  }

  Future<bool> _deleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to remove the code?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Beware that this action will not disable two factor authentication from your account'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, false);
                return false;
              },
            ),
            FlatButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.pop(context, true);
                return true;
              },
            ),
          ],
        );
      },
    );
  }
}

class OtpItem {
  int id;
  String secret;
  String issuer;
  String label;
  bool timeBased;
  String otpCode;

  OtpItem({this.id, this.secret, this.issuer, this.label, this.timeBased});

  factory OtpItem.fromMap(Map<String, dynamic> json) =>
      new OtpItem(
        id: json['id'],
        secret: json['secret'],
        issuer: json['issuer'],
        label: json['label'],
        timeBased: json['time_based'],
      );

  Map<String, dynamic> toMap() =>
      {
        'id': id,
        'secret': secret,
        'issuer': issuer,
        'label': label,
        'time_based': timeBased,
      };
}
