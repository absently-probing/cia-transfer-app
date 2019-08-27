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
  dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Expanded(
            child: QRView(
              key: _qrKey,
              onQRViewCreated: (controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((qrCode) {
                  String url;
                  String password;

                  // split qr code in url and optional password at first space
                  var i = qrCode.indexOf(' ');
                  if (i < 0) {
                    url = qrCode;
                  } else {
                    url = qrCode.substring(0, i);
                    password = qrCode.substring(i + 1);
                  }

                  if (_isValidUrl(url)) {
                    controller.pauseCamera();
                    controller.dispose();
                    Navigator.of(context, rootNavigator: true).pop([url, password]);
                  }
                });
              },
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            )
          ),
        ],
    );
  }

  bool _isValidUrl(String str) {
    return validators.isURL(str,
        protocols: ['https'],
        requireTld: true,
        requireProtocol: true,
        // TODO: logical error in validators lib, maybe do our own validation or delegate to cloud providers
        hostBlacklist: ['www.google.com', 'www.dropbox.com']);
  }
}
