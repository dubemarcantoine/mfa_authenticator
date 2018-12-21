import 'dart:async';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

class OtpList extends StatefulWidget {
  final List<OtpItem> otpItems = [
    OtpItem('prem7biaeqvisstc', 'Github', 'dubemarcantoine'),
    OtpItem('asdfasdf', 'Github', 'dubemarcantoine'),
  ];

  OtpList() {
    this.generateCodes();
  }

  @override
  _OtpListState createState() => _OtpListState();

  void generateCodes() {
    this.otpItems.forEach((otpItem) => otpItem.otpCode = OTP.generateTOTPCode(
        otpItem.secret, DateTime.now().millisecondsSinceEpoch));
  }
}

class _OtpListState extends State<OtpList> {
  @override
  void initState() {
    final int timeUntilNextRefresh = (DateTime.now().second - 30).abs();
    print(timeUntilNextRefresh);
    Future.delayed(
        Duration(seconds: timeUntilNextRefresh), () => _startTimer());
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: widget.otpItems.length,
        itemBuilder: (context, index) {
          final item = widget.otpItems[index];

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

  void _setOtpCodesFromSecrets() {
    setState(() {
      widget.generateCodes();
    });
  }

  void _startTimer() {
    this._setOtpCodesFromSecrets();
    new Timer.periodic(
        Duration(seconds: 30), (Timer t) => this._setOtpCodesFromSecrets());
  }
}

class OtpItem {
  final String secret;
  final String issuer;
  final String label;
  int otpCode;

  OtpItem(this.secret, this.issuer, this.label);
}
