import 'package:flutter/material.dart';
import '../../../data/utils.dart' as utils;
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
        if (utils.isValidUrl(qrSplitted[0])) {
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
}
