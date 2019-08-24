library globals;

import 'dart:math';

double maxHeight = 0;
double maxWidth = 0;

// logo
double cloudIcon = min(100.0, maxHeight / 8);
double lockIcon = min(50.0, cloudIcon / 2);

// pager_indicator.dart
double pagerIndicatorHeight = 45.0;
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
double onboardBottomPadding = 2 * pagerIndicatorHeight;
double onboardTopPadding = 15.0;
double onboardTextHeight = maxHeight - onboardBottomPadding - onboardTopPadding - cloudIcon - lockIcon - onboardIconTopPadding;