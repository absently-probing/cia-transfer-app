import 'package:flutter/material.dart';
import 'package:secure_upload/ui/screens/encrypt_path_second_screen.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:secure_upload/backend/cloud/google/cloudClient.dart';
import 'package:secure_upload/backend/cloud/google/googleDriveClient.dart';
import 'package:secure_upload/backend/cloud/google/mobileStorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:secure_upload/ui/screens/my_onboard_screen.dart';

import 'dart:io';


class EncryptScreen extends StatefulWidget {
  EncryptScreen({Key key}) : super(key: key);

  @override
  _EncryptScreen createState() => new _EncryptScreen();
}

class _EncryptScreen extends State<EncryptScreen>{
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _stateKey = new GlobalKey<FormState>();

  String _password;
  String _url;

  List<List<String>> _paths = [];
  Map<String, String> _path = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void performLogin() {
    final snackbar = new SnackBar(
        content: new Text(
            "Decryption Successful!, Email : $_url, password : $_password"));
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _openFileExplorer() async {
    Map<String, String> _tmp_paths = null;
    try {
      _tmp_paths = await FilePicker.getMultiFilePath();
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;

    setState(() {
      if (_tmp_paths != null) {
        for (String key in _tmp_paths.keys) {
          if (!_path.containsKey(_tmp_paths[key])) {
            _paths.add([key, _tmp_paths[key]]);
            _path[_tmp_paths[key]] = key;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(Strings.appTitle),
      ),
      body: Container(key: _stateKey,
          child: new Stack(children: <Widget>[
          new Column(
            children: <Widget>[
              new Expanded(
                child: new ListView.builder(
                    padding: const EdgeInsets.only(top: 10.0),
                    itemCount: _paths.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      final item = _paths[index][1];

                      return new Dismissible(
                          key: Key(item),
                          onDismissed: (direction) {
                            setState(() {
                              _path.remove(_paths[index][1]);
                              _paths.removeAt(index);
                            });
                          },
                          child: new Card(
                              child: new ListTile(
                            title: new Text(_paths[index][0]),
                            subtitle: new Text(_paths[index][1]),
                          )));
                    }),
              ),
            ],
          ),
          //Spacer(),
          new Padding(
            padding: EdgeInsets.only(
                top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: new FloatingActionButton(
                heroTag: "addFile",
                backgroundColor: Colors.blue,
                onPressed: () => _openFileExplorer(),
                child: new Container(
                  child: Transform.scale(
                    scale: 2,
                    child: new Text("+"),
                  ),
                ),
              ),
            ),
          ),
          new Padding (
              padding: EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: new Align(
                alignment: Alignment.bottomRight,
                child: new FloatingActionButton(
                  heroTag: "upload",
                  onPressed: () async {
                    //TODO add navigation screen for cloud file path
                    //TODO encrypt and upload after naviagetion screen
                    //TODO add loading screen for encrypt and upload
                    Storage storage = MobileStorage();
                    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
                    CloudClient client = GoogleDriveClient(storage);
                    await client.authenticate(launchURL);
                    var localFile = File("/storage/emulated/0/Download/flower.jpg");
                    var fileID = await client.createFile("myupload", localFile);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SecondEncrypt(
                                "dropbox.com/asdjio1231", "password1111117890123890127301270371203790127390127903120937890")));
                  },
                  child: new Stack(children: <Widget>[
                    new Container(
                      child: Icon(
                        Icons.cloud_queue,
                        color: Colors.white,
                      ),
                    ),
                  ]),
                ),
              )),
        ])
      ),
    );

  }
}
