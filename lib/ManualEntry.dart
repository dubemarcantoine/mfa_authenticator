import 'package:flutter/material.dart';

class  ManualEntry extends StatefulWidget {
  @override
  _ManualEntryState createState() => _ManualEntryState();
}

class _ManualEntryState extends State<ManualEntry> {
  final _formKey = GlobalKey<FormState>();
  bool timeBased = true;

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
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Issuer'
            ),
          ),
          SwitchListTile(
            value: this.timeBased,
            title: Text('Time based'),
            onChanged: (bool newValue) {
              setState(() {
                this.timeBased = newValue;
              });
            },
          )
        ],
      ),
    );
  }

  VoidCallback _submitForm() {
    return () {
      if (_formKey.currentState.validate()) {

      }
    };
  }
}