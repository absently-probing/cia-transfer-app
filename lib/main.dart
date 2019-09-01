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
      colorScheme: ColorScheme(
        primary: Colors.cyan[600],
        primaryVariant: Colors.cyan[700],
        secondary: Colors.redAccent[100],
        secondaryVariant: Colors.redAccent[200],
        surface: Colors.grey[800],
        background: Colors.grey[900],
        error: Colors.purple[300],
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.grey[700],
        onError: Colors.white,
        brightness: Brightness.light
      ),
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
