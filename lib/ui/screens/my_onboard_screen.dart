
import 'package:secure_upload/data/global.dart' as globals;
import 'package:flutter/material.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/ui/widgets/custom_buttons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pages = [
  new PageViewModel(
    Colors.blueGrey,
    Strings.appTitle,
    new Text(
      Strings.appTitle,
      softWrap: true,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: Strings.titleTextFont,
        fontWeight: FontWeight.w700,
        fontSize: 15.0,
      ),
    ),
  ),
  new PageViewModel(
      Colors.blueGrey,
      Strings.appTitle,
      new ConstrainedBox(
        constraints: new BoxConstraints(
          maxHeight: globals.onboardTextHeight,
        ),
      child: new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: new Text(
        Strings.appUsing,
        softWrap: true,
        textAlign: TextAlign.center,
        style: new TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
          fontFamily: Strings.titleTextFont,
          fontWeight: FontWeight.w700,
          fontSize: 15.0,
          ),
        ),
      ),
      ),
      ),
  new PageViewModel(
    Colors.blueGrey,
    Strings.appTitle,
      new Container(
        child: new Column(
          children: <Widget>[
            new Text('Please Select a Cloud Storage',
              style: new TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontFamily: Strings.titleTextFont,
                fontWeight: FontWeight.w700,
                fontSize: 15.0,
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: new SelectCloudWithButton(_handleButtonClick),
            ),

          ],

        )
        ),

    ),

];

_dontShowWalkthroughAgain() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('showWalkthrough', false);
}

_launchURL() async {
  const url = 'https://flutter.dev';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_handleButtonClick(BuildContext context, String sProvider) {
  _dontShowWalkthroughAgain();
  if (sProvider == null){
    // widget.prefs.setBool('encrypt',false);
    Navigator.of(context).pushNamed("/root");
  } else {
    // widget.prefs.setBool('encrypt',true);
    String url= "https://www.google.de";
    _launchURL();
    Navigator.of(context).pushReplacementNamed("/root");}
}

class Page extends StatelessWidget {

  final PageViewModel viewModel;
  final double iconPercentVisible;
  final double titlePercentVisible;
  final double textPercentVisible;

  Page({
    this.viewModel,
    this.iconPercentVisible = 0.5,
    this.titlePercentVisible = 1.0,
    this.textPercentVisible = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.infinity,
      color: viewModel.color,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Opacity(
            opacity: iconPercentVisible,
            child: new Padding(
                padding: new EdgeInsets.only(top: globals.onboardIconTopPadding, bottom: 0.0),
                child: new Stack(
                  children: <Widget>[
                    new Container(
                      child: Icon(
                        Icons.cloud_queue,
                        size: globals.cloudIcon,
                        color: Colors.white,
                      ),
                    ),
                    new Container(
                      child: Icon(
                        Icons.lock_outline,
                        size: globals.lockIcon,
                      ),
                    ),
                  ],
                ),
              ),
          ),
          new Opacity(
            opacity: titlePercentVisible,
            child: new Text(
                    viewModel.title,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontFamily: Strings.titleTextFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 24.0,
                    ),
            ),
          ),
          new Opacity(
            opacity: titlePercentVisible,
            child: new Padding(
              padding: new EdgeInsets.only(top: globals.onboardTopPadding, bottom: 10.0),
              child: viewModel.body,
            ),
          ),
        ],
      ),
    );
  }
}

class PageViewModel {
  final Color color;
  final String title;
  final Widget body;


  PageViewModel(
    this.color,
    this.title,
    this.body,

  );
}
