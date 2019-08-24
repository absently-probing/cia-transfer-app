import 'package:flutter/material.dart';
import 'package:secure_upload/ui/screens/encrypt_path_second_screen.dart';
import 'package:secure_upload/data/strings.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';



class EncryptScreen extends StatefulWidget {
  EncryptScreen({Key key}) : super(key: key);

  @override
  _EncryptScreen createState() => new _EncryptScreen();
}

class _EncryptScreen extends State<EncryptScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _stateKey = new GlobalKey<FormState>();

  String _password;
  String _url;


  List<List<String>> _paths = [];

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
        content: new Text("Decryption Successful!, Email : $_url, password : $_password")
    );
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
              _paths.add([key, _tmp_paths[key]]);
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
        body: new Form(
            key: _stateKey,
            child: new Stack(
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new Padding(
                        padding : EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
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
                      new Expanded(
                        child: new ListView.builder(
                            padding: const EdgeInsets.only(top: 10.0),
                            itemCount: _paths.length,
                            itemBuilder: (BuildContext ctxt, int index){
                              final item = UniqueKey().toString();

                              return new Dismissible(
                                  key: Key(item),
                                  onDismissed: (direction) {
                                    setState(() {
                                      _paths.removeAt(index);
                                    });},
                                  child: new Card(
                                      child: new ListTile(
                                        title: new Text(_paths[index][0]),
                                        subtitle: new Text(_paths[index][1]),
                                      )
                                  )
                              );
                            }),
                      ),
                    ],
                  ),
                //Spacer(),
                new Padding(
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                    child: new Align(
                      alignment: Alignment.bottomRight,
                      child: new FloatingActionButton(
                        heroTag: "upload",
                        onPressed: (){
                          Navigator.push(context,
                             MaterialPageRoute(builder:(context)=>SecondEncrypt())
                          );
                          },
                        child: new Stack(
                            children: <Widget>[
                              new Container(
                                child: Icon(
                                  Icons.cloud_queue,
                                  color: Colors.white,
                                ),
                              ),
                            ]),
                      ),
                    )
                ),
                ])
        ),
    );
  }
}
