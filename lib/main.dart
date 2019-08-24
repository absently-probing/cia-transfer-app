import 'package:flutter/material.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secure_upload/ui/screens/my_walkthrough_screen.dart';
import 'package:secure_upload/ui/screens/my_root_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var showWalkthrough = prefs.getBool('showWalkthrough') ?? true;
  runApp(MaterialApp(
    title: Strings.appTitle,
    debugShowCheckedModeBanner: false,
    routes: <String, WidgetBuilder>{
      '/walkthrough': (BuildContext context) => new MyWalkthroughScreen(),
      '/root': (BuildContext context) => new MyRootScreen(),
    },
    home: showWalkthrough ? new MyWalkthroughScreen() : new MyRootScreen(),
    theme: ThemeData(
      primaryColor: Colors.blueGrey,
      primarySwatch: Colors.grey,
    ),
  ));
}
