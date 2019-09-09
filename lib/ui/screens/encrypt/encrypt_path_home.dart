import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show Platform;

import 'encrypt_path_cloud_selection.dart';
import '../../../data/strings.dart';
import '../../../data/path.dart';

class EncryptScreen extends StatefulWidget {
  EncryptScreen({Key key}) : super(key: key);

  @override
  _EncryptScreen createState() => _EncryptScreen();
}

class _EncryptScreen extends State<EncryptScreen> {
  final Color _buttonColorUnusable = Colors.grey;
  final Color _buttonColorUsable = Colors.blue;
  Color _buttonColor = Colors.grey;

  List<List<String>> _paths = [];
  Map<String, String> _path = {};

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

      if (_paths.length > 0) {
        _buttonColor = _buttonColorUsable;
      } else {
        _buttonColor = _buttonColorUnusable;
      }
    });
  }

  void _openEncryptLoadingScreen(BuildContext context) async {
    List<String> files = [];
    for (String key in _path.keys) {
      files.add(key);
    }

    if (files.length > 0) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EncryptCloud(files: files)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.Sharing),
      ),
      body: Container(
          child: Stack(children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10.0),
                      itemCount: _paths.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        final item = _paths[index][1];
                        String showFile = _paths[index][0];

                        if (Platform.isAndroid && _paths[index][1].startsWith(Path.androidStoragePrefix)){
                          showFile = _paths[index][1].replaceFirst(Path.androidStoragePrefix, "");
                        }

                        return Dismissible(
                            key: Key(item),
                            onDismissed: (direction) {
                              setState(() {
                                _path.remove(_paths[index][1]);
                                _paths.removeAt(index);

                                if (_paths.length > 0) {
                                  _buttonColor = _buttonColorUsable;
                                } else {
                                  _buttonColor = _buttonColorUnusable;
                                }
                              });
                            },
                            child: Card(
                                child: ListTile(
                              title: Text(showFile,
                                  style: Theme.of(context).textTheme.body1),
                            )));
                      }),
                ),
              ],
            ),
            //Spacer(),
            Padding(
              padding: EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  heroTag: "addFile",
                  onPressed: () => _openFileExplorer(),
                  child: Container(
                    child: Transform.scale(
                      scale: 2,
                      child: Text("+"),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    backgroundColor: _buttonColor,
                    heroTag: "upload",
                    onPressed: () {
                      _openEncryptLoadingScreen(context);
                    },
                    child: Stack(children: <Widget>[
                      Container(
                        child: Icon(
                          Icons.cloud_queue,
                        ),
                      ),
                    ]),
                  ),
                )),
          ])),
    );
  }
}
