import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPages {
  List<PageViewModel> createStaticPageViewModels(BuildContext context) {
    return [
      PageViewModel(
        Strings.appTitle,
        Text(
          Strings.appDescription,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
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
          height: globals.onboardMaxPageHeight(context),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              child: Text(
                Strings.appUsing,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
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
      ),
    ];
  }

  _dontShowWalkthroughAgain() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWalkthrough', false);
  }
}

class Page extends StatelessWidget {
  final PageViewModel viewModel;
  final double iconPercentVisible;
  final double titlePercentVisible;
  final double textPercentVisible;

  Page({
    this.viewModel,
    this.iconPercentVisible = 1.0,
    this.titlePercentVisible = 1.0,
    this.textPercentVisible = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: iconPercentVisible,
            child: Padding(
              padding: EdgeInsets.only(top: globals.onboardIconTopPadding),
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.cloud_queue,
                      size: globals.cloudIcon(context),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Container(
                    child: Icon(
                      Icons.lock_outline,
                      size: globals.lockIcon(context),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Opacity(
            opacity: titlePercentVisible,
            child: Text(
              viewModel.title,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                decoration: TextDecoration.none,
                fontFamily: Strings.titleTextFont,
                fontWeight: FontWeight.w700,
                fontSize: globals.logoFontSize,
              ),
            ),
          ),
          Opacity(
            opacity: titlePercentVisible,
            child: Padding(
              padding: EdgeInsets.only(
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

  PageViewModel(
    this.title,
    this.body,
  );
}
