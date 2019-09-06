import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

import '../../../backend/cloud/cloudClient.dart';
import '../../../data/strings.dart';
import 'encrypt_path_progress_bar.dart';
import '../../../data/utils.dart' as utils;


class EncryptCloudCredentials extends StatefulWidget {
  final List<String> files;
  final CloudClient cloudClient;

  EncryptCloudCredentials({@required this.files, @required this.cloudClient});

  _EncryptCloudCredentialsState createState() =>
      _EncryptCloudCredentialsState(files: files, cloudClient: cloudClient);
}

class _EncryptCloudCredentialsState extends State<EncryptCloudCredentials> {
  final List<String> files;
  final CloudClient cloudClient;

  _EncryptCloudCredentialsState({this.files, this.cloudClient});

  void _onClickContinue(BuildContext context) async {
    await cloudClient.authenticate(utils.openURL);
    DeviceApps.openApp("de.fuberlin.imp.secure_upload");

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EncryptProgress(
                files: files, cloudProvider: cloudClient.provider)));
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      centerTitle: true,
      title: Text(Strings.encryptCloudCredentials),
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
          children: [
              Padding(
                padding: EdgeInsets.only(left: 30, right: 30, top: (utils.screenHeight(context) - utils.screenSafeAreaPadding(context) - appBar.preferredSize.height) / 8, bottom: 20),
                child: Text(
                  "You are using ${providerToString(cloudClient.provider)} for the first time. To authorize you against ${providerToString(cloudClient.provider)} you have to log in to the service in a browser window, which is opend when you click on continue.", //TODO: put in strings
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
                  child: OutlineButton(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    color: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      _onClickContinue(context);
                    },
                    child: Text('Continue', // TODO put in Strings
                        style: Theme.of(context).accentTextTheme.title),
                  ),
                ),
              ),
            ],
        ),
    );
  }
}
