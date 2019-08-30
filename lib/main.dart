import 'package:flutter/material.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secure_upload/ui/screens/onboarding/walkthrough_screen.dart';
import 'package:secure_upload/ui/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var showWalkthrough = prefs.getBool('showWalkthrough') ?? true;
  runApp(MaterialApp(
    title: Strings.appTitle,
    debugShowCheckedModeBanner: false,
    routes: <String, WidgetBuilder>{
      '/walkthrough': (BuildContext context) => WalkthroughScreen(),
      '/root': (BuildContext context) => HomeScreen(),
    },
    home: showWalkthrough ? WalkthroughScreen() : HomeScreen(),
    theme: ThemeData(
      primaryColor: Colors.blueGrey,
      primarySwatch: Colors.grey,
      hintColor: Colors.black,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(),
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 24.0,
        ),
      ),
    ),
  ));
}
