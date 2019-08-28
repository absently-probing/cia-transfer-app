import 'package:flutter/material.dart';
import 'package:secure_upload/ui/widgets/custom_buttons.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/data/global.dart' as globals;
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
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.appTitle),
        actions: <Widget>[
          MainContextMenu(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView (
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Opacity(
                opacity: iconPercentVisible,
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 0.0, left: 0),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        child: Icon(
                          Icons.cloud_queue,
                          size: globals.cloudIcon(context),
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        child: Icon(
                          Icons.lock_outline,
                          size: globals.lockIcon(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Opacity(
                opacity: titlePercentVisible,
                child: Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 15.0, right: 0),
                    child: Text(
                      Strings.appTitle,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
              child: Padding(
                padding: EdgeInsets.only(
                    top: 15.0, bottom: 10.0, left: 20.00, right: 20.00),
                child: MainScreenButtons(),
              ),
            ),
          ],
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: SizedBox(
              width: globals.rootButtonWidth(context),
              height: globals.rootButtonHeight(context),

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
          Padding(
            padding: EdgeInsets.all(20.0),
            child: SizedBox(
              width: globals.rootButtonWidth(context),
              height: globals.rootButtonHeight(context),
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
