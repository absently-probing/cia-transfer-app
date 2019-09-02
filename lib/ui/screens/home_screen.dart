import 'package:flutter/material.dart';
import 'package:secure_upload/ui/custom/menus.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/ui/screens/decrypt/decrypt_path_home.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_home.dart';
import 'package:secure_upload/ui/screens/onboarding/walkthrough_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  final double _iconPercentVisible = 1.0;
  final double _titlePercentVisible = 1.0;

  HomeScreen();

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
                    children: <Widget>[
                      Container(
                        child: Icon(
                          Icons.cloud_queue,
                          size: globals.cloudIcon(context),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Container(
                        child: Icon(
                          Icons.lock_outline,
                          size: globals.lockIcon(context),
                          color: Theme.of(context).colorScheme.secondary
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
                        child: OutlineButton.icon(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          hoverColor: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            _encryptButtonAction(context);
                          },
                          icon: Icon(Icons.cloud_upload,),
                          label: Text(Strings.homeScreenEncryptLabel.toUpperCase(),
                              style: TextStyle(fontSize: 20)),
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
                          label: Text(Strings.homeScreenDecryptLabel.toUpperCase(),
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
