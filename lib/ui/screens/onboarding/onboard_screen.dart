import '../../../data/strings.dart';
import '../../../data/global.dart' as globals;
import '../../custom/logo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPages {
  List<PageViewModel> createStaticPageViewModels(BuildContext context) {
    return [
      PageViewModel(
        Strings.appTitle,
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Text(
            Strings.appDescription,
            softWrap: true,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subhead,
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
                style: Theme.of(context).textTheme.body1,
              ),
            ),
          ),
        ),
      ),
    ];
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
                children: SecureUploadLogoSecondary().draw(context),
              ),
            ),
          ),
          Opacity(
            opacity: titlePercentVisible,
            child: Text(
              viewModel.title,
              softWrap: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.display1,
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
