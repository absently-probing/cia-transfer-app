import 'package:flutter/material.dart';
import 'package:secure_upload/backend/cloud/cloudClient.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_progress_bar.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_zip_progress.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:secure_upload/data/utils.dart' as utils;

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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ZipProgress(files: files, cloudProvider: cloudClient.provider)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.encryptCloudCredentials),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                "You are using ${providerToString(cloudClient.provider)} for the first time. To authorize you against ${providerToString(cloudClient.provider)} you have to log in to the service in a browser window, which is opend when you click on continue.", //TODO: put in strings
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontFamily: Strings.titleTextFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 20.0,
                ),
              ),
              OutlineButton(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                color: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  _onClickContinue(context);
                },
                child: Text('Continue', // TODO put in Strings
                    style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
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
    if (sProvider == null) {
      // widget.prefs.setBool('encrypt',false);
    } else {
      // widget.prefs.setBool('encrypt',true);
      String url = "https://www.google.de";
      _launchURL();
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil("/root", (Route<dynamic> route) => false);
  }
}
