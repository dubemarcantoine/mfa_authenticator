import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mfa_authenticator/components/AppDrawer.dart';
import 'package:mfa_authenticator/components/CountdownTimer.dart';
import 'package:mfa_authenticator/components/OtpOptionFabMenu.dart';
import 'package:mfa_authenticator/data/OtpItemDataMapper.dart';
import 'package:mfa_authenticator/model/OtpItem.dart';
import 'package:otp/otp.dart';

final key = new GlobalKey<_OtpListState>();

class OtpList extends StatefulWidget {
  String title;

  OtpList({this.title}) : super(key: key);

  @override
  _OtpListState createState() => _OtpListState();
}

class _OtpListState extends State<OtpList>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<OtpItem> otpItems = [];
  CancelableOperation initialCountdown;
  Timer refreshTimer;

  int timeUntilRefresh = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        this.initialCountdown = null;
        this.refreshTimer = null;
        this._startInitialCountdown();
        break;
    }
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
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
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
              this.generateCodes();
            }
            return buildList();
          }),
      floatingActionButton: OtpOptionFabMenu(),
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
              new Divider(height: 0.0, color: Colors.grey),
            ],
          );
        });
  }

  void addOtpItem(OtpItem otpItem) async {
    otpItem.id = await OtpItemDataMapper.newOtpItem(otpItem);
    setState(() {
      generateCode(otpItem);
      this.otpItems.add(otpItem);
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Code added successfully!'),
    ));
  }

  void generateCodes() {
    this.otpItems.forEach((otpItem) => generateCode(otpItem));
  }

  void generateCode(OtpItem otpItem) {
    otpItem.otpCode =
        "${OTP.generateTOTPCode(otpItem.secret, DateTime.now().millisecondsSinceEpoch)}"
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
    this.refreshTimer = Timer.periodic(Duration(seconds: this.timeUntilRefresh),
        (Timer t) => this._setOtpCodesFromSecrets());
  }

  void _setOtpCodesFromSecrets() {
    print("Refreshing... Next in ${this.timeUntilRefresh} secs");
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
                Text(
                    'Beware that this action will not disable two factor authentication from your account'),
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