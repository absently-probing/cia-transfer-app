import 'package:flutter/material.dart';

Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double screenHeight(BuildContext context) {
  return screenSize(context).height;
}

double screenWidth(BuildContext context) {
  return screenSize(context).width;
}

double screenSafeAreaPadding(BuildContext context){
  return MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom;
}