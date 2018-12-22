import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mfa_authenticator/data/OtpItemDataMapper.dart';
import 'package:otp/otp.dart';

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

  Widget buildList() {
    print('building list');
    return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: this.otpItems.length,
        itemBuilder: (context, index) {
          final item = this.otpItems[index];
          return Column(
            children: <Widget>[
              ListTile(
                title: Text("${item.otpCode}"),
                subtitle: Text(item.issuer),
              ),
              Divider(),
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
}

class OtpItem {
  final int id;
  final String secret;
  final String issuer;
  final String label;
  int otpCode;

  OtpItem({this.id, this.secret, this.issuer, this.label});

  factory OtpItem.fromMap(Map<String, dynamic> json) =>
      new OtpItem(
        id: json['id'],
        secret: json['secret'],
        issuer: json['issuer'],
        label: json['label'],
      );

  Map<String, dynamic> toMap() =>
      {
        'id': id,
        'secret': secret,
        'issuer': issuer,
        'label': label,
      };
}
