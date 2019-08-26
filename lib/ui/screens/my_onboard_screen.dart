import 'package:secure_upload/data/global.dart' as globals;
import 'package:flutter/material.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/ui/widgets/custom_buttons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

final pages = [
  PageViewModel(
    Strings.appTitle,
    Text(
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
  PageViewModel(
    Strings.appTitle,
    SizedBox(
      height: globals.onboardTextHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Text(
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
    portraitOnly: true,
  ),
  PageViewModel(
    Strings.appTitle,
    Container(
        child: Column(
      children: <Widget>[
        Text(
          'Please Select a Cloud Storage',
          style: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
            fontFamily: Strings.titleTextFont,
            fontWeight: FontWeight.w700,
            fontSize: 15.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: SelectCloudWithButton(_handleButtonClick),
        ),
      ],
    )),
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
  if (sProvider == null) {
    // widget.prefs.setBool('encrypt',false);
  } else {
    // widget.prefs.setBool('encrypt',true);
    String url = "https://www.google.de";
    _launchURL();
  }

  Navigator.of(context).pushNamedAndRemoveUntil("/root", (Route<dynamic> route) => false);
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
    if (viewModel.portraitOnly){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }


    return new Container(
      width: double.infinity,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Opacity(
            opacity: iconPercentVisible,
            child: new Padding(
              padding: new EdgeInsets.only(top: globals.onboardIconTopPadding),
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
                fontSize: globals.logoFontSize,
                height: globals.onboardLogoTextHeight,
              ),
            ),
          ),
          new Opacity(
            opacity: titlePercentVisible,
            child: new Padding(
              padding: new EdgeInsets.only(
                  top: globals.onboardTopPadding,
                  bottom: globals.onboardIconBottomPadding),
              child: viewModel.body,
            ),
          ),
        ],
      ),
    );
  }
}

class PageViewModel {
  final String title;
  final Widget body;
  final bool portraitOnly;

  PageViewModel(
    this.title,
    this.body,
    {this.portraitOnly = false}
  );
}
