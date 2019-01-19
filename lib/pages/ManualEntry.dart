import 'package:flutter/material.dart';
import 'package:mfa_authenticator/pages/OtpList.dart';
import 'package:mfa_authenticator/model/OtpItem.dart';

class  ManualEntry extends StatefulWidget {
  @override
  _ManualEntryState createState() => _ManualEntryState();
}

class _ManualEntryState extends State<ManualEntry> {
  final _formKey = GlobalKey<FormState>();
  OtpItem otpItem = OtpItem();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Entry'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: 'Submit',
            onPressed: _submitForm(),
          ),
        ],
      ),
      body: Center(
        child: buildForm(context),
      ),
    );
  }

  @override
  Widget buildForm(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Secret Key'
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'The secret key is required';
              }
            },
            onSaved: (value) {
              this.otpItem.secret = value;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Account'
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'The account field is required';
              }
            },
            onSaved: (value) {
              this.otpItem.label = value;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Issuer'
            ),
            onSaved: (value) {
              this.otpItem.issuer = value;
            },
          ),
//          SwitchListTile(
//            value: this.otpItem.timeBased != null ? this.otpItem.timeBased : true,
//            title: Text('Time based'),
//            onChanged: (bool newValue) {
//              setState(() {
//                this.otpItem.timeBased = newValue;
//              });
//            },
//          )
        ],
      ),
    );
  }

  VoidCallback _submitForm() {
    return () {
      if (this._formKey.currentState.validate()) {
        this._formKey.currentState.save();
        key.currentState.addOtpItem(otpItem);
        Navigator.pop(context, true);
      }
    };
  }
}