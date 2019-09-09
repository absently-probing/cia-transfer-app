import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_upload/data/strings.dart';

class ShareQr extends StatelessWidget {
  final String _url;
  final String _password;

  ShareQr(this._url, this._password);

  void _finishButton(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/root', (Route<dynamic> route) => false);
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
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      Strings.shareQrInfo,
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 40, right: 40, bottom: 60),
                    child: Container(
                      child: QrImage(
                        data: _url + " " + _password,
                        version: QrVersions.auto,
                        padding: EdgeInsets.all(25),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 7),
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                    ),
                  ),
                ],
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
                child: Icon(Icons.check),
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
