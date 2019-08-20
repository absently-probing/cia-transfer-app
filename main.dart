import 'package:flutter/material.dart';
import 'secondscreen.dart';
import 'previousscreen.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(),
      home: new FormPage(),
    );
  }
}

class FormPage extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<FormPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final stateKey = new GlobalKey<FormState>();

  String _url;
  String _password;

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

  void _submit() {
    final form = stateKey.currentState;

    if (form.validate()) {
      form.save();



      Navigator.push(context,
          MaterialPageRoute(builder:(context)=>SecondScreen())

      );

      //performLogin();



    }
  }

  void performLogin() {


    final snackbar = new SnackBar(
      content: new Text("Decryption Successful!, Email : $_url, password : $_password")
    );
    scaffoldKey.currentState.showSnackBar(snackbar);

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          leading: IconButton(icon: new Icon(Icons.arrow_back_ios), onPressed: (){
            Navigator.push(context,
            MaterialPageRoute(builder:(context)=>PreviousScreen())
            );
          }),
          title: new Text("Secure Upload"),
        ),
        body: new Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 250.0, bottom: 10.0),
          child: new Form(
            key: stateKey,
            child: new Column(
              children: <Widget>[
                new TextFormField(
                  decoration: new InputDecoration(labelText: "Enter URL here"
                  ),
                  validator: (val) =>
                  !val.contains('@') ? 'Invalid Link' : null,
                  onSaved: (val) => _url = val,
                ),
                new TextFormField(
                  decoration: new InputDecoration(labelText: "Enter Password"),
                  validator: (val) =>
                  val.length < 6 ? 'Wrong Password' : null,
                  onSaved: (val) => _password = val,
                  obscureText: true,
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 170.0, bottom: 100.0),
                ),
                new RaisedButton(
                  child: new Text(
                    "Decrypt",
                    style: new TextStyle(color: Colors.white),
                  ),
                  color: Colors.blue,

                  onPressed: _submit

                )
              ],
            ),
          ),
        ));
  }
}