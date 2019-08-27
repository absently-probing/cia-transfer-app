import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/ui/custom/progress_indicator.dart';

class DecryptProgress extends StatefulWidget {
  final String url;
  final String password;

  DecryptProgress({@required this.url, @required this.password});

  _DecryptProgressState createState() =>
      _DecryptProgressState(url: url, password: password);
}

class _DecryptProgressState extends State<DecryptProgress> {
  final String url;
  final String password;

  _DecryptProgressState({this.url, this.password});

  Widget build(BuildContext context) {
    return WillPopScope(
        //onWillPop: () async => false,
        child: Container(
          color: Theme.of(context).primaryColor,
          child: CircularPercentIndicator(
            radius: globals.maxWidth / 2,
            animation: true,
            lineWidth: 5.0,
            percent: 0.1,
            center: new Text("10%"),
      ),
    ));
  }
}
