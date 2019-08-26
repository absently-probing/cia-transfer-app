library globals;

import 'dart:math';

double maxHeight = 0;
double maxWidth = 0;

// logo
double cloudIcon = min(100.0, maxHeight / 8);
double lockIcon = min(50.0, cloudIcon / 2);

double logoFontSize = 24.0;

// pager_indicator.dart
double paperIndicatorWidth = 45.0;
double indicatorMinWidth = 20.0;
double indicatorMaxWidth = 40.0;
double indicatorMinHeight = 20.0;
double indicatorMaxHeight = 40.0;

// page_dragger.dart
double transitionPixels = maxHeight / 4;

// my_root_screen.dart
double rootButtonWidth = min(300.0, maxWidth);
double rootButtonHeight = min(100.0, maxHeight / 10);

// my_onboard_screen.dart
double onboardIconTopPadding = 30.0;
double onboardIconBottomPadding = 10.0;
double onboardIndicatorBottomPadding = 20.0;
double onboardIndicatorTopPadding = 10.0;
double onboardTopPadding = 15.0;
double onboardTextScaleFactor = 0.0;
double onboardLogoTextHeight = 1.3;

double onboardTextHeight = maxHeight
    - (indicatorMaxHeight + onboardIndicatorBottomPadding + onboardIndicatorTopPadding
        + onboardIconTopPadding + cloudIcon
        + onboardTopPadding + onboardIconBottomPadding +  onboardLogoTextHeight * logoFontSize * onboardTextScaleFactor + 1.0);