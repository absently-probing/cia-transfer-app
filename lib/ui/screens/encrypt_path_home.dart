import 'package:flutter/material.dart';
import 'package:secure_upload/ui/screens/encrypt_path_second_screen.dart';
import 'package:secure_upload/data/strings.dart';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';



class EncryptScreen extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<EncryptScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final stateKey = new GlobalKey<FormState>();

  String _password;
  String _url;


  Map<String,String> _paths;
  String _fileName;

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
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _openFileExplorer() async {
      try {
          _paths = await FilePicker.getMultiFilePath();
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;

      setState(() {
        _fileName =
             _paths != null ? _paths.keys.toString() : '...';
      });
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(Strings.appTitle),
        ),
        body: new Center(
        child: new Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 100.0, bottom: 10.0),
          child: new Form(
            key: stateKey,
            child: new Column(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: new RaisedButton(
                    onPressed: () => _openFileExplorer(),
                    child: new Text("Open file picker"),
                  ),
                ),
               new RaisedButton(
                 onPressed: (){
                   Navigator.push(context,
                       MaterialPageRoute(builder:(context)=>SecondEncrypt())

                   );
                 },
                 child: new Text("Upload")
               ),


                new Builder(
                  // TODO: make this prettier
                  builder: (BuildContext context) =>
                   _paths != null
                      ? new Container(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        height: MediaQuery.of(context).size.height * 0.50,
                        child: new Scrollbar(
                         child: new ListView.separated(
                          itemCount: _paths != null && _paths.isNotEmpty
                              ? _paths.length
                              : 1,
                          itemBuilder: (BuildContext context, int index) {
                            final bool isMultiPath =
                                _paths != null && _paths.isNotEmpty;
                            final String name = 'File $index: ' +
                                (isMultiPath
                                    ? _paths.keys.toList()[index]
                                    : _fileName ?? '...');
                            final path = _paths.values.toList()[index].toString();

                            return new ListTile(
                              title: new Text(
                                name,
                              ),
                              subtitle: new Text(path),
                            );
                          },
                          separatorBuilder:
                              (BuildContext context, int index) =>
                          new Divider(),
                        )),
                  )
                      : new Container(),
                ),
              ],
            ),
          ),
        )));
  }
}
