import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:mfa_authenticator/data/OtpItemDataMapper.dart';

final key = new GlobalKey<_OtpListState>();

class OtpList extends StatefulWidget {

  OtpList() : super(key: key);

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

  Widget buildList() {
    print('building list');
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

  void addOtpItem(OtpItem otpItem) async {
    otpItem.id = await OtpItemDataMapper.newOtpItem(otpItem);
    setState(() {
      generateCode(otpItem);
      this.otpItems.add(otpItem);
    });
  }

  void generateCodes() {
    this.otpItems.forEach((otpItem) => generateCode(otpItem));
  }

  void generateCode(OtpItem otpItem) {
    otpItem.otpCode = "${OTP.generateTOTPCode(otpItem.secret, DateTime.now().millisecondsSinceEpoch)}"
        .padLeft(6, '0');
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
