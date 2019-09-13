import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart' as val;
import '../backend/cloud/cloudClient.dart' as cloud;

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

bool isValidProvider(String url, {cloud.CloudProvider matchProvider}){
  var split = url.split('://');

  if (split.length < 2){
    return false;
  }

  split = split[1].split('/');

  if (split.length < 2 ){
    return false;
  }

  if (matchProvider != null){
    if(split[0].startsWith(cloud.providerDomain(matchProvider))){
      return true;
    }

    return false;
  }

  for (String domain in cloud.providerDomains()){
    if (split[0].startsWith(domain)){
      return true;
    }
  }

  return false;
}

bool isValidUrl(String url) {
  if (!val.isURL(url, protocols: ["https"], requireProtocol: true)) {
    return false;
  }

  return isValidProvider(url);
}