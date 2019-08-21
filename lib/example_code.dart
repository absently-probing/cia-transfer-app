// Flutter code sample for material.DropdownButton.1

// This sample shows a `DropdownButton` whose value is one of
// "One", "Two", "Free", or "Four".

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: new SizedBox(
          width: 200,
          height: 200,
          child: MyDropdownMenu(),
        )
      ),
    );
  }
}

class MyDropdownMenu extends StatefulWidget {
  MyDropdownMenu({Key key}) : super(key: key);

  @override
  _MyDropdownMenuState createState() => _MyDropdownMenuState();
}

class _MyDropdownMenuState extends State<MyDropdownMenu> {
  String dropdownValue = 'Select Cloud Storage Provider';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownButton<String>(
          value: dropdownValue,
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
            });
          },
          items: <String>['Select Cloud Storage Provider','Dropbox', 'GoogleDrive', 'OneDrive']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}