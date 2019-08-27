import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_upload/data/global.dart' as globals;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_upload/ui/widgets/custom_buttons.dart';
import 'package:share/share.dart';

class Constants{
  static const String url = 'Share URL only';
  static const String password = 'Share Password only';
  static const String both = 'Share both';

  static const List<String> choices = <String>[
    url,
    password,
    both
  ];
}

class SecondEncrypt extends StatelessWidget {
  final String _url;
  final String _password;

  SecondEncrypt(this._url, this._password);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final key = new GlobalKey<ScaffoldState>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    void choiceAction(String choice){
      if(choice == Constants.password){
        Share.share('Password:' + '' + _password);
      }else if(choice == Constants.url){
        Share.share('Url:' + '' + _url);
      }else if(choice == Constants.both){
        Share.share('Link:'+ '' + _url + '' + 'Password:' + '' + _password);
      }
    }
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: new Text("Upload Complete"),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Icon(Icons.share, size: 30.0),
            offset: Offset(0, 55),
            elevation: 10,
            onSelected: choiceAction,
            itemBuilder: (BuildContext context){
              const PopupMenuDivider();
              return Constants.choices.map((String choice){
                const PopupMenuDivider();
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
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
                                      onLongPress: () {
                                        Clipboard.setData(
                                            new ClipboardData(text: _url));
                                        key.currentState
                                            .showSnackBar(new SnackBar(
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
                                      key.currentState
                                          .showSnackBar(new SnackBar(
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
                      size: globals.maxWidth / 2,
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
