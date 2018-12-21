import 'dart:async';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

class OtpList extends StatefulWidget {
  final List<OtpItem> otpItems = [
    OtpItem('asdf', 'Github', 'dubemarcantoine'),
    OtpItem('asdfasdf', 'Github', 'dubemarcantoine'),
  ];

  @override
  _OtpListState createState() => _OtpListState();
}

class _OtpListState extends State<OtpList> {
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
                title: Text(
                    "${OTP.generateTOTPCode(item.secret, DateTime.now().millisecondsSinceEpoch)}"),
                subtitle: Text(item.issuer),
              ),
              Divider(),
            ],
          );
        });
  }
}

class OtpItem {
  final String secret;
  final String issuer;
  final String label;
  int otpCode;

  OtpItem(this.secret, this.issuer, this.label);
}
