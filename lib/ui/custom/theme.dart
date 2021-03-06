import 'package:flutter/material.dart';

final themes = {
  "darkBlueTheme": ThemeData(
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
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
        brightness: Brightness.light),
    buttonTheme: ButtonThemeData(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
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
            //onSurface: Colors.white, fixed textfield copy/paste dialog
            onSurface: Colors.black,
            onBackground: Colors.grey[700],
            onError: Colors.white,
            brightness: Brightness.light)),
    textTheme: TextTheme(
        body1: TextStyle(color: Colors.white, fontFamily: "Didactic Gothic"),
        body2: TextStyle(color: Colors.white),
        title: TextStyle(color: Colors.black),
        subtitle: TextStyle(color: Colors.redAccent[100]),
        subhead: TextStyle(color: Colors.white),
        button: TextStyle(color: Colors.cyan[600]),
        headline: TextStyle(color: Colors.white),
        display1: TextStyle(color: Colors.white,
          decoration: TextDecoration.none,
          fontFamily: "OpenSans",
          fontWeight: FontWeight.w700,
          fontSize: 24,),
    ),
    primaryColor: Colors.cyan[600],
    primaryTextTheme: TextTheme(
        body1: TextStyle(fontFamily: "Didactic Gothic"),
        title: TextStyle(color: Colors.black),
        button: TextStyle(color: Colors.black)),
    accentColor: Colors.redAccent[100],
    accentTextTheme: TextTheme(
      title: TextStyle(color: Colors.cyan[600]),
        button: TextStyle(color: Colors.black)
    ),
    backgroundColor: Colors.grey[900],
    scaffoldBackgroundColor: Colors.grey[900],
    cardTheme: CardTheme(color: Colors.grey[800]),
    cardColor: Colors.grey[800],
    primaryIconTheme: IconThemeData(color: Colors.black),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
      labelStyle: TextStyle(
        color: Colors.black,
        fontSize: 24.0,
      ),
    ),
  ),
};
