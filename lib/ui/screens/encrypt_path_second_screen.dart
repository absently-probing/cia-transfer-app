import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_upload/ui/widgets/custom_buttons.dart';
import 'package:share/share.dart';
import 'package:secure_upload/data/strings.dart';

class SecondEncrypt extends StatefulWidget {
  final String _url;
  final String _password;

  SecondEncrypt(this._url, this._password);

  _SecondEncryptState createState() =>
      _SecondEncryptState(this._url, this._password);
}

class _SecondEncryptState extends State<SecondEncrypt> {
  final String _url;
  final String _password;
  final _key = GlobalKey<ScaffoldState>();


  _SecondEncryptState(this._url, this._password);

  void _choiceAction(String choice) {
    //TODO fix encoding
    if (choice == Strings.encryptSharePassword) {
      Share.share('Password:' + '' + _password);
    } else if (choice == Strings.encryptShareUrl) {
      Share.share('Url:' + '' + _url);
    } else if (choice == Strings.encryptShareBoth) {
      Share.share('Link:' + '' + _url + '' + 'Password:' + '' + _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: new Text("Upload Complete"),
        actions: <Widget>[
          EncryptShareMenu(_choiceAction),
        ],
      ),
      body: Container(
        child: Stack(children: [
          Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 50.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: GestureDetector(
                                      child: CustomText(
                                          text: _url,
                                          icon: new Icon(Icons.cloud_download),
                                          fontSize: 20,
                                          width: 200),
                                      onTap: () {
                                        Clipboard.setData(
                                            new ClipboardData(text: _url));
                                        _key.currentState
                                            .showSnackBar(new SnackBar(
                                          duration: Duration(milliseconds: 400),
                                          content: new Text("URL copied"),
                                        ));
                                      })),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 20.0),
                                child: GestureDetector(
                                    child: CustomText(
                                        text: _password,
                                        icon: Icon(Icons.lock),
                                        fontSize: 12,
                                        width: 200),
                                    onTap: () {
                                      Clipboard.setData(
                                          new ClipboardData(text: _url));
                                      _key.currentState
                                          .showSnackBar(new SnackBar(
                                        duration: Duration(milliseconds: 400),
                                        content: new Text("Password copied"),
                                      ));
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    QrImage(
                      data: _url + " " + _password,
                      version: QrVersions.auto,
                      size: utils.screenWidth(context) / 2,
                    ),
                  ]),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                // TODO: when pushing this button reset history stack

                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/root', (Route<dynamic> route) => false);
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
