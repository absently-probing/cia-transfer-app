import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:secure_upload/backend/cloud/google/cloudClient.dart';
import 'package:secure_upload/backend/cloud/google/mobileStorage.dart';
import 'package:secure_upload/main.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_cloud_credentials.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_progress_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/data/utils.dart' as utils;

class EncryptCloud extends StatefulWidget {
  final List<String> files;

  EncryptCloud({@required this.files});

  _EncryptCloudState createState() => _EncryptCloudState(files: files);
}

class _EncryptCloudState extends State<EncryptCloud> {
  final List<String> files;

  _EncryptCloudState({this.files});

  void _cloudProviderButtonAction(
      BuildContext context, CloudProvider cloudProvider) async {
    Storage storage = MobileStorage();

    // TODO: is this needed?
    // Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    CloudClient client = CloudClientFactory.create(cloudProvider, storage);

    if (await client.hasCredentials()) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EncryptProgress(
                  files: files, cloudClient: client)));
      await client.authenticate(utils.openURL);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EncryptCloudCredentials(
                  files: files, cloudClient: client)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.appTitle),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                Strings.encryptSelectCloudProvider,
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontFamily: Strings.titleTextFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(
                height: globals.onboardMaxPageHeight(context), //TODO
                child: ListView.separated(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: cloudStorageProviders.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      // color: Colors.white,
                      child: Center(
                        child: OutlineButton(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            _cloudProviderButtonAction(
                                context, cloudStorageProviders[index].provider);
                          },
                          child: Text('${cloudStorageProviders[index].name}',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
            ],
          ),
        ),
        /*
        child: Center(
          child: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              Text(
                'Please Select a Cloud Storage',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontFamily: Strings.titleTextFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: SelectCloudWithButton(_handleButtonClick),
              ),
            ],
          )),
        ),
        */
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
