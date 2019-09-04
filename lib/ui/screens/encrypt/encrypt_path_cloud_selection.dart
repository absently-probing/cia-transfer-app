import 'package:flutter/material.dart';
import '../../../backend/cloud/cloudClient.dart';
import '../../../backend/storage/mobileStorage.dart';
import 'encrypt_path_cloud_credentials.dart';
import '../../../data/strings.dart';
import '../../../data/global.dart' as globals;
import 'encrypt_path_progress_bar.dart';

class EncryptCloud extends StatefulWidget {
  final List<String> files;

  EncryptCloud({@required this.files});

  _EncryptCloudState createState() => _EncryptCloudState(files: files);
}

class _EncryptCloudState extends State<EncryptCloud> {
  final List<String> files;

  _EncryptCloudState({this.files});

  void _cloudProviderTapAction(
      BuildContext context, CloudProvider cloudProvider) async {
    MobileStorage storage = MobileStorage();

    // TODO: is this needed?
    // Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    CloudClient client = CloudClientFactory.create(cloudProvider, storage);

    if (await client.hasCredentials()) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EncryptProgress(files: files, cloudProvider: cloudProvider)));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EncryptCloudCredentials(files: files, cloudClient: client)));
    }
  }

  List<Widget> _createCloudProviderList() {
    List<Widget> entries = List<Widget>();
    for (int i = 0; i < CloudProvider.values.length; i++) {
      entries.add(Padding(
        padding: EdgeInsets.only(right: 40, left: 40, top: 20, bottom: 20),
        child: SizedBox(
          width: globals.rootButtonWidth(context),
          height: globals.rootButtonHeight(context),

          //Adding Correct Button depending on Prefs-Setting
          child: OutlineButton(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
            hoverColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              _cloudProviderTapAction(context, CloudProvider.values[i]);
            },
            //icon: Icon(
            //  Icons.cloud_upload,
            //),
            child: Text(
                '${providerToString(CloudProvider.values[i])}',
                style: TextStyle(fontSize: 20)),
          ),
        ),
      ),);
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.encryptCloudSelection),
      ),
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          children: _createCloudProviderList(),
        )),
      ),
    );
  }
}
