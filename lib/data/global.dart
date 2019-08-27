library globals;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/data/utils.dart' as utils;

// logo
double cloudIcon(BuildContext context) {
  return min(100.0, utils.screenHeight(context) / 8);
}

double lockIcon(BuildContext context) {
  return min(50.0, cloudIcon(context) / 2);
}

  double logoFontSize = 24.0;

// pager_indicator.dart
  double paperIndicatorWidth = 45.0;
  double indicatorMinWidth = 20.0;
  double indicatorMaxWidth = 40.0;
  double indicatorMinHeight = 20.0;
  double indicatorMaxHeight = 40.0;

// page_dragger.dart
  double transitionPixels(BuildContext context) {
    return utils.screenHeight(context) / 4;
  }

// my_root_screen.dart
  double rootButtonWidth(BuildContext context){
    return min(300.0, utils.screenHeight(context));
  }

  double rootButtonHeight(BuildContext context) {
    return min(100.0, utils.screenHeight(context) / 10);
  }

// my_onboard_screen.dart
  double onboardIconTopPadding = 30.0;
  double onboardIconBottomPadding = 10.0;
  double onboardIndicatorBottomPadding = 20.0;
  double onboardIndicatorTopPadding = 10.0;
  double onboardTopPadding = 15.0;
  double onboardLogoHeight(context) {
    final constraints = BoxConstraints(
      maxWidth: utils.screenWidth(context), // maxwidth calculated
      minHeight: 0.0,
      minWidth: 0.0,
    );

    RenderParagraph renderParagraph = RenderParagraph(
      TextSpan(
        text: Strings.appTitle,
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
          fontFamily: Strings.titleTextFont,
          fontWeight: FontWeight.w700,
          fontSize: logoFontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    renderParagraph.layout(constraints);
    return renderParagraph.getMinIntrinsicHeight(logoFontSize).ceilToDouble();
  }

  double onboardMaxPageHeight(BuildContext context){
    return utils.screenHeight(context)
      - (indicatorMaxHeight + onboardIndicatorBottomPadding + onboardIndicatorTopPadding
          + onboardIconTopPadding + cloudIcon(context)
          + onboardTopPadding + onboardIconBottomPadding +  onboardLogoHeight(context));
  }