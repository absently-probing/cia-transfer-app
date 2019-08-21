import 'package:flutter/material.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secure_upload/ui/screens/my_walkthrough_screen.dart';
import 'package:secure_upload/ui/screens/my_root_screen.dart';

void main() {
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs: prefs));
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  MyApp({this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/walkthrough': (BuildContext context) => new MyWalkthroughScreen(),
        '/root': (BuildContext context) => new MyRootScreen(),
      },
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        primarySwatch: Colors.grey,
      ),
      home: _handleCurrentScreen(),
    );
  }

  Widget _handleCurrentScreen() {
    bool seen = (prefs.getBool('seen') ?? false);
    if (seen) {
      return new MyRootScreen(prefs: prefs);
    } else {
      return new MyWalkthroughScreen(prefs: prefs);
    }
  }
}



