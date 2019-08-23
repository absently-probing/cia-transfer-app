import 'package:flutter/material.dart';
import 'package:secure_upload/ui/widgets/custom_buttons.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/ui/screens/decrypt_path_home.dart';
import 'package:secure_upload/ui/screens/encrypt_path_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'encrypt_path_home.dart';


class MyRootScreen extends StatefulWidget {
  @override

  createState() => new _MyRootScreenState();
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

class _MyRootScreenState extends State<MyRootScreen> {
  final double iconPercentVisible = 0.5;
  final double titlePercentVisible = 1.0;
  final double textPercentVisible = 0.75;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.appTitle),
        actions: <Widget>[
          new MyPopupMenuButton(),
        ],
      ),
      body: new Container(
        width: double.infinity,
        color: Colors.blueGrey,
        child: new Column(
          children: [
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Opacity(
                  opacity: iconPercentVisible,
                  child: new Padding(
                    padding:
                        new EdgeInsets.only(top: 10.0, bottom: 0.0, left: 40.0),
                    child: new Stack(
                      children: <Widget>[
                        new Container(
                          child: Icon(
                            Icons.cloud_queue,
                            size: 100.00,
                            color: Colors.white,
                          ),
                        ),
                        new Container(
                          child: Icon(
                            Icons.lock_outline,
                            size: 50.00,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                new Opacity(
                  opacity: titlePercentVisible,
                  child: new Padding(
                      padding:
                          EdgeInsets.only(top: 10.0, bottom: 15.0, right: 40.0),
                      child: new Text(
                        Strings.appTitle,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontFamily: Strings.titleTextFont,
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0,
                        ),
                      )),
                ),
              ],
            ),
            new Expanded(
              child: new Opacity(
                opacity: titlePercentVisible,
                child: new Padding(
                  padding: EdgeInsets.only(
                      top: 15.0, bottom: 100.0, left: 20.00, right: 20.00),
                  child: new MainScreenButtons(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreenButtons extends StatefulWidget {
  @override
  createState() => new _MainScreenButtonsState();
}

/// This is the stateless widget that the main application instantiates.
class _MainScreenButtonsState extends State<MainScreenButtons> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Padding(
            padding: new EdgeInsets.all(20.0),
            child: new SizedBox(
              width: 300,
              height: 100,
              
                  //Adding Correct Button depending on Prefs-Setting
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EncryptScreen()),
                  );
                },
                child: const Text('Encryption',
                    style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
          new Padding(
            padding: new EdgeInsets.all(20.0),
            child: new SizedBox(
              width: 300,
              height: 100,
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DecryptScreen()),
                  );
                },
                child: const Text('Decrypt',
                    style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EncryptSceen {
}
