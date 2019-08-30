import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

void openURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}