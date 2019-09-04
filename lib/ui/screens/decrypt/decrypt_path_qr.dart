import 'package:flutter/material.dart';

import 'package:validators/validators.dart' as validators;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class DecryptQr extends StatefulWidget {
  _DecryptQrState createState() => _DecryptQrState();
}

class _DecryptQrState extends State<DecryptQr> {
  QRViewController controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  _DecryptQrState();

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  void _qrViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((qrCode) {
      var qrSplitted = qrCode.split(' ');
      if (qrSplitted.length == 2) {
        if (_isValidUrl(qrSplitted[0])) {
          controller.pauseCamera();
          controller.dispose();
          Navigator.of(context, rootNavigator: true).pop(qrSplitted);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: QRView(
        key: _qrKey,
        onQRViewCreated: _qrViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.primary,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }

  bool _isValidUrl(String str) {
    return validators.isURL(str,
        protocols: ['https'],
        requireTld: true,
        requireProtocol: true,
        // TODO: logical error in validators lib, maybe do our own validation or delegate to cloud providers
        hostBlacklist: ['drive.google.com', 'www.dropbox.com']);
  }
}
