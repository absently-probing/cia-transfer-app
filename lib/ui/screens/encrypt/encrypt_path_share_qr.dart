import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_upload/ui/custom/text.dart';
import 'package:secure_upload/ui/custom/menus.dart';
import 'package:share/share.dart';
import 'package:secure_upload/data/strings.dart';

class ShareQr extends StatelessWidget {
  final String _url;
  final String _password;

  ShareQr(this._url, this._password);

  void _finishButton(BuildContext context){
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/root', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.shareQrTitle),
      ),
      body: Container(
        child: Stack(children: [
          Container(
            color: Theme.of(context).colorScheme.background,
            padding: EdgeInsets.all(45),
            child: Center(
              child: Container(
                child: QrImage(
                  data: _url + " " + _password,
                  version: QrVersions.auto,
                  padding: EdgeInsets.all(25),
                  //size: utils.screenWidth(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 7),
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  _finishButton(context);
                },
                child: Icon(Icons.thumb_up),
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
