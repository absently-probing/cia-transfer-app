import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_upload/ui/custom/text.dart';
import 'package:secure_upload/ui/custom/menus.dart';
import 'package:share/share.dart';
import 'package:secure_upload/data/strings.dart';

class FinalEncrypt extends StatefulWidget {
  final String _url;
  final String _password;

  FinalEncrypt(this._url, this._password);

  _FinalEncryptState createState() =>
      _FinalEncryptState(this._url, this._password);
}

class _FinalEncryptState extends State<FinalEncrypt> {
  final String _url;
  final String _password;
  final _key = GlobalKey<ScaffoldState>();


  _FinalEncryptState(this._url, this._password);

  void _choiceAction(String choice) {
    //TODO fix encoding
    if (choice == Strings.encryptSharePassword) {
      Share.share(_password);
    } else if (choice == Strings.encryptShareUrl) {
      Share.share(_url);
    } else if (choice == Strings.encryptShareBoth) {
      Share.share(_url + '\n' + _password);
    }
  }

  void _copyUrl(){
    Clipboard.setData(
        ClipboardData(text: _url));
    _key.currentState
        .showSnackBar(SnackBar(
      duration: Duration(milliseconds: 400),
      content: Text("URL copied"),
    ));
  }

  void _copyPassword(){
    Clipboard.setData(
        ClipboardData(text: _url));
    _key.currentState
        .showSnackBar(SnackBar(
      duration: Duration(milliseconds: 400),
      content: Text("Password copied"),
    ));
  }

  void _finishButton(BuildContext context){
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/root', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Upload Complete"),
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
                                          icon: Icon(Icons.cloud_download),
                                          fontSize: 20,
                                          width: 200),
                                      onTap: _copyUrl
                                  )),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 20.0),
                                child: GestureDetector(
                                    child: CustomText(
                                        text: _password,
                                        icon: Icon(Icons.lock),
                                        fontSize: 12,
                                        width: 200),
                                    onTap: _copyPassword
                                ),
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
