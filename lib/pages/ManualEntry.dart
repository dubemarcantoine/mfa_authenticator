import 'package:flutter/material.dart';
import 'package:authenticator/model/OtpItem.dart';
import 'package:authenticator/pages/OtpList.dart';

class ManualEntry extends StatefulWidget {
  @override
  _ManualEntryState createState() => _ManualEntryState();
}

class _ManualEntryState extends State<ManualEntry> {
  static const int MIN_DIGIT_COUNT = 6;
  final _formKey = GlobalKey<FormState>();
  OtpItem _otpItem = OtpItem();
  final List<int> _possibleDigits = List.generate(
      MIN_DIGIT_COUNT + 1, (int index) => MIN_DIGIT_COUNT + index);

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
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildMandatoryForm(context),
              _buildOptionalFormFields(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMandatoryForm(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Mandatory Parameters'),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Secret Key'),
                  maxLines: 3,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'The secret key is required';
                    }
                  },
                  onSaved: (value) {
                    this._otpItem.secret = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Issuer'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'The issuer is required';
                    }
                  },
                  onSaved: (value) {
                    this._otpItem.issuer = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Account'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'The account is required';
                    }
                  },
                  onSaved: (value) {
                    this._otpItem.account = value;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalFormFields(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Optional Parameters'),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
            child: Column(
              children: <Widget>[
                FormField(
                  builder: (FormFieldState state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Digits',
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _otpItem.digits?.toString(),
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _otpItem.digits = int.parse(newValue);
                            });
                          },
                          items: _possibleDigits.map((value) {
                            return DropdownMenuItem<String>(
                              value: value?.toString(),
                              child: Text(value?.toString()),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback _submitForm() {
    return () {
      if (this._formKey.currentState.validate()) {
        this._formKey.currentState.save();
        otpListKey.currentState.addOtpItem(_otpItem);
        Navigator.pop(context, true);
      }
    };
  }
}
