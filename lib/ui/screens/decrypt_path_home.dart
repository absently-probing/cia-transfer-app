import 'package:flutter/material.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/ui/widgets/custom_buttons.dart';
import 'package:secure_upload/ui/custom/icons.dart';
import 'package:secure_upload/ui/custom/overlay.dart';

class DecryptScreen extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<DecryptScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _stateKey = new GlobalKey<FormState>();
  final _focusNodeUrl = new FocusNode();
  final _focusNodePassword = new FocusNode();

  String _url;
  String _password;
  bool _urlHasFocus = false;
  bool _passwordHasFocus = false;
  bool _passwordHadFocus = false;



  String _urlValidationResult = null;
  String _passwordValidationResult = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNodeUrl.addListener(_handleUrlTextField);
    _focusNodePassword.addListener(_handlePassworTextField);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNodeUrl.dispose();
    _focusNodePassword.dispose();
  }

  void _submit() async {
    final form = await _stateKey.currentState;

    if (form.validate()) {
      form.save();

      if (_url != "" && _password != "") {
        performLogin();
      }
    }
  }

  String _urlValidator(String input) {
    if (!_passwordHadFocus && input.isEmpty){
      return _urlValidationResult;
    }

    if (!input.contains('@')) {
      _urlValidationResult = 'Invalid Link';
    } else {
      _urlValidationResult = null;
    }

    return _urlValidationResult;
  }

  String _passwordValidator(String input) {
    if (!_passwordHadFocus){
      print("Hi");
      return null;
    }

    if (input.isEmpty) {
      _passwordValidationResult = "Required";
    } else {
      _passwordValidationResult = null;
    }

    return _passwordValidationResult;
  }

  // use Navigator.of(context, rootNavigator: true).pop('dialog') to close dialog after
  // successfully parsed qrcode
  void _openQRCodeScanner(BuildContext _context) {
    showDialog(
      context: _context,
        builder: (BuildContext context) {
        return CustomOverlay(
          child:  Container(
            height: globals.maxHeight,
            color: Colors.green,
          )
        );
      },
    );
  }

  void performLogin() {
    final snackbar = new SnackBar(
      content: new Text("Decryption Successful!"),
      //, Email : $_url, password : $_password
      action: SnackBarAction(
        label: 'Download',
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              "/root", (Route<dynamic> route) => false);
        },
      ),
      duration: const Duration(minutes: 5),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _handleUrlTextField() {
    if (_focusNodeUrl.hasFocus){
      _urlHasFocus = true;
    } else {
      if (_urlHasFocus){
        _urlHasFocus = false;
        print("start");
        _submit();
        print("fin");
      }
    }
  }

  void _handlePassworTextField() {
    if (_focusNodePassword.hasFocus){
      _passwordHasFocus = true;
    } else {
      if (_passwordHasFocus){
        _passwordHasFocus = false;
        _passwordHadFocus = true;
        _submit();
      }
    }
  }

  //button widgets
  Widget filledButton(String text, Color splashColor, Color highlightColor,
      Color fillColor, Color textColor, void function()) {
    return RaisedButton(
      highlightElevation: 0.0,
      splashColor: splashColor,
      highlightColor: highlightColor,
      elevation: 0.0,
      color: fillColor,
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.bold, color: textColor, fontSize: 20),
      ),
      onPressed: () {
        function();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(Strings.appTitle),
          actions: [
IconButton(
                icon: Icon(CustomIcons.qrcode_scanner),
                tooltip: Strings.scannerTooltip,
                onPressed: (){
                  _openQRCodeScanner(context);
                },
              ),
          ],
        ),
        body: Center(
            child: Container(
          width: globals.maxWidth,
          alignment: Alignment.center,
          color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
              child: Form(
                  key: _stateKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: CustomTextField(
                              focusNode: _focusNodeUrl,
                              onSaved: (input) => _url = input,
                              validator: _urlValidator,
                              icon: Icon(Icons.cloud_download),
                              hint: "URL",
                              autofocus: true,
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: CustomTextField(
                              focusNode: _focusNodePassword,
                              onSaved: (val) => _password = val,
                              obsecure: true,
                              validator: _passwordValidator,
                              hint: "Password",
                              icon: Icon(Icons.lock),
                              autofocus: false,
                            )),
                        /*Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: SizedBox(
                                height: globals.rootButtonHeight,
                                width: globals.rootButtonWidth,
                                child: filledButton(
                                    'Decrypt',
                                    Theme.of(context).hintColor,
                                    Theme.of(context).buttonColor,
                                    Theme.of(context).buttonColor,
                                    Theme.of(context).hintColor,
                                    _submit)),
                          ),
                        ),*/
                      ]))),
        )));
  }
}
