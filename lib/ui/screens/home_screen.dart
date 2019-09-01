import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_upload/ui/custom/menus.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/ui/screens/decrypt/decrypt_path_home.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_home.dart';
import 'package:secure_upload/ui/screens/onboarding/walkthrough_screen.dart';
import 'package:libsodium/libsodium.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final double _iconPercentVisible = 0.5;
  final double _titlePercentVisible = 1.0;

  HomeScreen();

  @override
  State<StatefulWidget> createState() =>
      _HomeScreenState(_iconPercentVisible, _titlePercentVisible);
}

class _HomeScreenState extends State<HomeScreen> {
  final double _iconPercentVisible;
  final double _titlePercentVisible;
  bool _libsodium;

  _HomeScreenState(this._iconPercentVisible, this._titlePercentVisible);

  @override
  void initState() {
    super.initState();
    _checkLibsodium();
  }

  Future<void> _checkLibsodium() async {
    _libsodium = Libsodium.supported();
  }

  void _menuAction(String input, BuildContext context) {
    if (input == Strings.mainContextMenuOnboarding) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WalkthroughScreen()),
      );
    }
  }

  void _encryptButtonAction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EncryptScreen()),
    );
  }

  void _decryptButtonAction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DecryptScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_libsodium) {
      return AlertDialog(
        content: Text("Sorry your Device is not supported yet."),
        actions: [
          FlatButton(
            child: Text("close"),
            onPressed: () async {
              await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          )
        ],
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.appTitle),
        actions: <Widget>[
          MainContextMenu(_menuAction),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Opacity(
                opacity: _iconPercentVisible,
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
                opacity: _titlePercentVisible,
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
            Opacity(
              opacity: _titlePercentVisible,
              child: Padding(
                padding: EdgeInsets.only(
                    top: 15.0, bottom: 10.0, left: 20.00, right: 20.00),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: globals.rootButtonWidth(context),
                        height: globals.rootButtonHeight(context),

                        //Adding Correct Button depending on Prefs-Setting
                        child: RaisedButton(
                          onPressed: () {
                            _encryptButtonAction(context);
                          },
                          child: const Text(Strings.homeScreenEncryptLabel,
                              style: TextStyle(fontSize: 20)),
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
                            _decryptButtonAction(context);
                          },
                          child: const Text(Strings.homeScreenDecryptLabel,
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
