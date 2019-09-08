import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../custom/menus.dart';
import '../../data/strings.dart';
import '../../data/global.dart' as globals;
import '../custom/logo.dart';
import 'decrypt/decrypt_path_home.dart';
import 'encrypt/encrypt_path_home.dart';
import 'encrypt/encrypt_path_share_selection.dart';
import 'onboarding/walkthrough_screen.dart';
import 'package:libsodium/libsodium.dart';

import 'dart:io';

class HomeScreen extends StatefulWidget {
  final double _iconPercentVisible = 1.0;
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
    // TODO: remove from production code, only for testing
    if (input == Strings.mainContextMenuOnboarding) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WalkthroughScreen()),
      );
    }
    if (input == Strings.shareSelectionTitle) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShareSelection("testurl", "testpw")),
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
        content: Text(
          "Sorry your Device is not supported yet.",
          style: Theme.of(context).textTheme.title,
        ),
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
                    children: SecureUploadLogoPrimary().draw(context),
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
                      Strings.welcome,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline,
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
                        child: OutlineButton.icon(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          hoverColor: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            _encryptButtonAction(context);
                          },
                          icon: Icon(
                            Icons.cloud_upload,
                          ),
                          label: Text(
                              Strings.homeScreenEncryptLabel.toUpperCase(),
                              style: Theme.of(context).accentTextTheme.title),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: globals.rootButtonWidth(context),
                        height: globals.rootButtonHeight(context),
                        child: OutlineButton.icon(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            _decryptButtonAction(context);
                          },
                          icon: Icon(Icons.cloud_download),
                          label: Text(
                              Strings.homeScreenDecryptLabel.toUpperCase(),
                              style: Theme.of(context).accentTextTheme.title),
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
