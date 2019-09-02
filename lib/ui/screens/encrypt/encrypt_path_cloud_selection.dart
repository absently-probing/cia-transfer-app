import 'package:flutter/material.dart';
import 'package:secure_upload/backend/cloud/cloudClient.dart';
import 'package:secure_upload/backend/storage/mobileStorage.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_cloud_credentials.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_zip_progress.dart';

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
                  ZipProgress(files: files, cloudProvider: cloudProvider)));
      await client.authenticate(utils.openURL);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EncryptCloudCredentials(files: files, cloudClient: client)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(Strings.encryptCloudSelection),
        ),
        body: Container(
            child: ListView.builder(
          itemCount: CloudProvider.values.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                '${providerToString(CloudProvider.values[index])}',
                style: TextStyle(fontSize: 20),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                _cloudProviderTapAction(
                    context, CloudProvider.values[index]);
              },
            );
          },
        )));
  }
}
