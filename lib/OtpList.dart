import 'dart:async';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:mfa_authenticator/data/OtpItemDataMapper.dart';

class OtpList extends StatefulWidget {

  @override
  _OtpListState createState() => _OtpListState();
}

class _OtpListState extends State<OtpList> {

  List<OtpItem> otpItems = [];

  @override
  void initState() {
    final int timeUntilNextRefresh = (DateTime.now().second - 29).abs();
    print("Time until next refresh ${timeUntilNextRefresh}");
    Future.delayed(
        Duration(seconds: timeUntilNextRefresh), () => _startTimer());
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return FutureBuilder<List<OtpItem>>(
        future: OtpItemDataMapper.getOtpItems(),
        builder: (BuildContext context, AsyncSnapshot<List<OtpItem>> snapshot) {
          print('data fetched');
          if (snapshot.hasData) {
            this.otpItems = snapshot.data;
            this.generateCodes();
          }
          return buildList();
        }
    );
  }

  void _removeOtpItem(OtpItem otpItem) {
    setState(() {
      this.otpItems.removeWhere((itemInList) => itemInList.id == otpItem.id);
    });
  }

  Widget buildList() {
    print('building list');
    return ListView.builder(
        padding: const EdgeInsets.only(left: 8.0),
        itemCount: this.otpItems.length,
        itemBuilder: (context, index) {
          final item = this.otpItems[index];
          return Column(
            children: <Widget>[
              new Slidable(
                delegate: new SlidableDrawerDelegate(),
                child: ListTile(
                  title: Text("${item.otpCode}"),
                  subtitle: Text(item.issuer),
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
            ],
          );
        });
  }

  void generateCodes() {
    this.otpItems.forEach((otpItem) => generateCode(otpItem));
  }

  void generateCode(OtpItem otpItem) {
    otpItem.otpCode = OTP.generateTOTPCode(otpItem.secret, DateTime.now().millisecondsSinceEpoch);
  }

  void _startTimer() {
    this._setOtpCodesFromSecrets();
    new Timer.periodic(
        Duration(seconds: 30), (Timer t) => this._setOtpCodesFromSecrets());
  }

  void _setOtpCodesFromSecrets() {
    setState(() {
      this.generateCodes();
    });
  }

  void _onDeleteTap(OtpItem item) async {
    final bool userResponse = await _deleteConfirmationDialog();
    if (userResponse) {
      await OtpItemDataMapper.delete(item.id);
      this._removeOtpItem(item);
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
  final int id;
  final String secret;
  final String issuer;
  final String label;
  final bool timeBased;
  int otpCode;

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
