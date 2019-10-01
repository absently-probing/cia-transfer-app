import 'package:flutter/material.dart';
import 'package:cia_transfer/ui/custom/theme.dart' as theme;
import 'package:cia_transfer/data/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cia_transfer/ui/screens/onboarding/walkthrough_screen.dart';
import 'package:cia_transfer/ui/screens/home_screen.dart';

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
    theme: theme.themes["darkBlueTheme"],
  ));
}
