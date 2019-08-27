import 'package:flutter/material.dart';
import 'package:secure_upload/ui/widgets/custom_buttons.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:secure_upload/ui/screens/decrypt_path_home.dart';
import 'package:secure_upload/ui/screens/encrypt_path_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'encrypt_path_home.dart';

/*
class MyRootScreen extends StatelessWidget {
  @override

  createState() => new _MyRootScreenState();
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}*/

class MyRootScreen extends StatelessWidget {
  final double iconPercentVisible = 0.5;
  final double titlePercentVisible = 1.0;
  final double textPercentVisible = 0.75;

  MyRootScreen();

  @override
  Widget build(BuildContext context) {
    globals.maxHeight = utils.screenHeight(context);
    globals.maxWidth = utils.screenWidth(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.appTitle),
        actions: <Widget>[
          new MainContextMenu(),
        ],
      ),
      body: new Container(
        width: double.infinity,
        color: Colors.blueGrey,
        child: new Column(
          children: [
            new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              new Opacity(
                opacity: iconPercentVisible,
                child: new Padding(
                  padding: new EdgeInsets.only(top: 10.0, bottom: 0.0, left: 0),
                  child: new Stack(
                    children: <Widget>[
                      new Container(
                        child: Icon(
                          Icons.cloud_queue,
                          size: globals.cloudIcon,
                          color: Colors.white,
                        ),
                      ),
                      new Container(
                        child: Icon(
                          Icons.lock_outline,
                          size: globals.lockIcon,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              new Opacity(
                opacity: titlePercentVisible,
                child: new Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 15.0, right: 0),
                    child: new Text(
                      Strings.appTitle,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontFamily: Strings.titleTextFont,
                        fontWeight: FontWeight.w700,
                        fontSize: globals.logoFontSize,
                      ),
                    )),
              ),
            ]),
            new Opacity(
              opacity: titlePercentVisible,
              child: new Padding(
                padding: EdgeInsets.only(
                    top: 15.0, bottom: 10.0, left: 20.00, right: 20.00),
                child: new MainScreenButtons(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MainScreenButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Padding(
            padding: new EdgeInsets.all(20.0),
            child: new SizedBox(
              width: globals.rootButtonWidth,
              height: globals.rootButtonHeight,

              //Adding Correct Button depending on Prefs-Setting
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EncryptScreen()),
                  );
                },
                child:
                const Text('Encryption', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
          new Padding(
            padding: new EdgeInsets.all(20.0),
            child: new SizedBox(
              width: globals.rootButtonWidth,
              height: globals.rootButtonHeight,
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DecryptScreen()),
                  );
                },
                child: const Text('Decrypt', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
