import 'package:flutter/material.dart';

import 'package:validators/validators.dart' as validators;

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class DecryptQr extends StatelessWidget {
  QRViewController controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
            flex: 4,
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      print(scanData);
      if (_validateQrCode(scanData)) {
        print("valid");
      }
    });
  }

  bool _validateQrCode(String str) {
    var seq = str.split(" ");
    if (seq.length < 1 || seq.length > 2) {
      return false;
    }
    return _validateUrl(seq[0]);
  }

  bool _validateUrl(String str) {
    return validators.isURL(str,
        protocols: ['https'],
        requireTld: true,
        requireProtocol: true,
        // TODO: logical error in validators lib, maybe do our own validation or delegate to cloud providers
        hostBlacklist: ['google.com', 'dropbox.com']);
  }
}
