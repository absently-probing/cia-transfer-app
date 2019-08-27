import 'package:flutter/material.dart';

import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/ui/screens/decrypt_path_qr.dart';
import 'package:secure_upload/ui/widgets/custom_buttons.dart';
import 'package:secure_upload/ui/custom/icons.dart';

class DecryptScreen extends StatefulWidget {
  @override
  _DecryptScreen createState() => new _DecryptScreen();
}

class _DecryptScreen extends State<DecryptScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _stateKey = new GlobalKey<FormState>();
  final _focusNodeUrl = new FocusNode();
  final _focusNodePassword = new FocusNode();

  var _urlController = TextEditingController();
  var _passwordController = TextEditingController();
  bool _urlHasFocus = false;
  bool _passwordHasFocus = false;
  bool _passwordHadFocus = false;

  bool _focusInit = true;

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

      if (_urlController.text != "" && _passwordController.text != "") {
        performLogin();
      }
    }
  }

  String _urlValidator(String input) {
    if (!_passwordHadFocus && input.isEmpty) {
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
    if (!_passwordHadFocus) {
      return null;
    }

    if (input.isEmpty) {
      _passwordValidationResult = "Required";
    } else {
      _passwordValidationResult = null;
    }

    return _passwordValidationResult;
  }

  _openQRCodeScanner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DecryptQr()),
    );

    if (result != null && result.length == 2) {
      _urlController.text = result[0];

      if (result[1] == null) {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text(Strings.scannerUpdatedUrl)));
      } else {
        _passwordController.text = result[1];
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text(Strings.scannerUpdatedUrlAndPasssword)));
      }
    }
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
    if (_focusNodeUrl.hasFocus) {
      _urlHasFocus = true;
    } else {
      if (_urlHasFocus) {
        _urlHasFocus = false;
        _submit();
      }
    }
  }

  void _handlePassworTextField() {
    if (_focusNodePassword.hasFocus) {
      _passwordHasFocus = true;
    } else {
      if (_passwordHasFocus) {
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
    if (_focusInit) {
      FocusScope.of(context).requestFocus(_focusNodeUrl);
      _focusInit = false;
    }

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(Strings.appTitle),
          actions: [
            IconButton(
              icon: Icon(CustomIcons.qrcode_scanner),
              tooltip: Strings.scannerTooltip,
              onPressed: () {
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
                              controller: _urlController,
                              focusNode: _focusNodeUrl,
                              validator: _urlValidator,
                              icon: Icon(Icons.cloud_download),
                              hint: Strings.decryptUrlTextField,
                              autofocus: false,
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: CustomTextField(
                              controller: _passwordController,
                              focusNode: _focusNodePassword,
                              obsecure: true,
                              validator: _passwordValidator,
                              hint: Strings.decryptPasswordTextField,
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
