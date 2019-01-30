import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:authenticator/components/AppDrawer.dart';
import 'package:authenticator/components/CountdownTimer.dart';
import 'package:authenticator/components/OtpOptionFabMenu.dart';
import 'package:authenticator/data/OtpItemDataMapper.dart';
import 'package:authenticator/helpers/TimeHelper.dart';
import 'package:authenticator/model/OtpItem.dart';
import 'package:otp/otp.dart';

final otpListKey = new GlobalKey<_OtpListState>();

class OtpList extends StatefulWidget {
  String title;

  OtpList({this.title}) : super(key: otpListKey);

  @override
  _OtpListState createState() => _OtpListState();
}

class _OtpListState extends State<OtpList>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<OtpItem> otpItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startInitialCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          CountdownTimer(),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<List<OtpItem>>(
          future: OtpItemDataMapper.getOtpItems(),
          builder:
              (BuildContext context, AsyncSnapshot<List<OtpItem>> snapshot) {
            if (snapshot.hasData) {
              this.otpItems = snapshot.data;
              this._generateCodesFromSecrets();
            }
            return _buildList();
          }),
      floatingActionButton: OtpOptionFabMenu(),
    );
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
        _startInitialCountdown();
        break;
    }
  }

  void addOtpItem(OtpItem otpItem) async {
    otpItem.id = await OtpItemDataMapper.newOtpItem(otpItem);
    setState(() {
      _generateCode(otpItem);
      this.otpItems.add(otpItem);
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Code added successfully!'),
    ));
  }

  void _startInitialCountdown() {
    this._setStateForOtpCodes();
    final int secondsUntilNextRefresh = TimeHelper.getSecondsUntilNextRefresh();
    CancelableOperation.fromFuture(Future.delayed(
        Duration(seconds: secondsUntilNextRefresh), () => _startTimer()));
  }

  void _startTimer() {
    this._setStateForOtpCodes();
    Timer.periodic(
        Duration(seconds: 30), (Timer t) => this._setStateForOtpCodes());
  }

  void _setStateForOtpCodes() {
    if (this.mounted) {
      setState(() {
        this._generateCodesFromSecrets();
      });
    }
  }

  void _generateCodesFromSecrets() {
    this.otpItems.forEach((otpItem) => _generateCode(otpItem));
  }

  void _generateCode(OtpItem otpItem) {
    final String generatedCode = OTP
        .generateTOTPCode(otpItem.secret, DateTime.now().millisecondsSinceEpoch,
            length: otpItem.digits)
        .toString();
    otpItem.otpCode = generatedCode.padLeft(otpItem.digits, '0');
  }

  Widget _buildList() {
    return ListView.builder(
        itemCount: this.otpItems.length,
        itemBuilder: (context, index) {
          final item = this.otpItems[index];
          return Column(
            children: <Widget>[
              new Slidable(
                delegate: new SlidableDrawerDelegate(),
                child: ListTile(
                  title: Text(
                    _formatOtpCode(item.otpCode),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.issuer ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(item.account ?? ''),
                    ],
                  ),
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
              new Divider(height: 0.0, color: Colors.grey),
            ],
          );
        });
  }

  String _formatOtpCode(String otpCode) {
    return otpCode?.splitMapJoin(RegExp('..'),
        onMatch: (m) => '${m.group(0)} ');
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
                Text('Beware that this action will not disable two factor '
                    'authentication from your associated account'),
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
