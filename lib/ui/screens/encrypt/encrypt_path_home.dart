import 'package:flutter/material.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_progress_bar.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:secure_upload/backend/cloud/google/cloudClient.dart';
import 'package:secure_upload/backend/cloud/google/googleDriveClient.dart';
import 'package:secure_upload/backend/cloud/google/mobileStorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:secure_upload/data/utils.dart' as utils;

import 'dart:io';


class EncryptScreen extends StatefulWidget {
  EncryptScreen({Key key}) : super(key: key);

  @override
  _EncryptScreen createState() => _EncryptScreen();
}

class _EncryptScreen extends State<EncryptScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _stateKey = GlobalKey<FormState>();

  String _password;
  String _url;
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
	});
  }

  void _openEncryptLoadingScreen(BuildContext context) async {
	List<String> files = [];
	for (String key in _path.keys){
	  files.add(key);
	}

	Storage storage = MobileStorage();
	Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
	CloudClient client = GoogleDriveClient(storage);
	if(!(await client.hasCredentials())) {
		await client.authenticate(utils.openURL);
	}
	var localFile = File("/storage/emulated/0/Download/flower.jpg");
	var fileID = await client.createFile("myupload", localFile);

	Navigator.push(
		context,
		MaterialPageRoute(
			builder: (context) => EncryptProgress(files: files)));
  }

  @override
  Widget build(BuildContext context) {
	return Scaffold(
	  key: _scaffoldKey,
	  appBar: AppBar(
		centerTitle: true,
		title: Text(Strings.appTitle),
	  ),
	  body: Container(key: _stateKey,
		  child: Stack(children: <Widget>[
		  Column(
			children: <Widget>[
			  Expanded(
				child: ListView.builder(
					padding: const EdgeInsets.only(top: 10.0),
					itemCount: _paths.length,
					itemBuilder: (BuildContext ctxt, int index) {
					  final item = _paths[index][1];

					  return Dismissible(
						  key: Key(item),
						  onDismissed: (direction) {
							setState(() {
							  _path.remove(_paths[index][1]);
							  _paths.removeAt(index);
							});
						  },
						  child: Card(
							  child: ListTile(
							title: Text(_paths[index][0]),
							subtitle: Text(_paths[index][1]),
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
				backgroundColor: Colors.blue,
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
				  heroTag: "upload",
				  onPressed: () {
					_openEncryptLoadingScreen(context);
				  },
				  child: Stack(children: <Widget>[
					Container(
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
