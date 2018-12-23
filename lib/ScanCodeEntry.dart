import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';

class ScanCodeEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan barcode/QR'),
      ),
    );
  }
}
