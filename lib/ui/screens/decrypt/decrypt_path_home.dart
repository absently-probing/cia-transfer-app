import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/strings.dart';
import '../../../data/constants.dart';
import '../../../data/utils.dart' as utils;
import 'decrypt_path_qr.dart';
import 'decrypt_path_metadata.dart';
import '../../custom/text_field.dart';
import '../../custom/icons.dart';

import 'dart:convert';

class DecryptScreen extends StatefulWidget {
  @override
  _DecryptScreen createState() => _DecryptScreen();
}

class _DecryptScreen extends State<DecryptScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _stateKey = GlobalKey<FormState>();

  var _urlEnabled = true;
  var _passwordEnabled = true;

  var _urlController = TextEditingController();
  var _passwordController = TextEditingController();

  _DecryptScreen(){
    _autoCopy();
  }

  void _autoCopy() async {
    var cData = await Clipboard.getData("text/plain");
    if (cData != null) {
      var content = cData.text;
      var ok = _checkForUrlAndPassword(content);
      if (ok){
        final snackBar = SnackBar(
          duration: Duration(milliseconds: 1000),
          content:
          Text('Copied from clipboard', style: Theme
              .of(context)
              .textTheme
              .title),
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .primary,
        );

        _releaseFocus();
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }

  void _submit() {
    final form = _stateKey.currentState;
    // use this to fast skip entering url and password
    //_urlController.text = "https://drive.google.com/uc?id=1E_ftaWTjbEp5RJssdrL4TFMs9HASB6Hj&export=download";
    //_passwordController.text = "f4ReJgBFpiK3jEjtHyFqrUq+8JFyFoaI4ogJz9KX5qs=";

    if (form.validate()) {
      form.save();

      if (_urlController.text != "" && _passwordController.text != "") {
        _openProgressBar(context);
      }
    }
  }

  String _urlValidator(String input) {
    if (!utils.isValidUrl(input)) {
      return 'Invalid Link';
    }

    return null;
  }

  String _passwordValidator(String input) {
    if (input.isEmpty || input.length != Consts.keySize) {
      return "Invalid password";
    }

    try {
      base64Decode(input);
    } catch (e) {
      return "Wrong password";
    }

    return null;
  }

  bool _checkForUrlAndPassword(String text){
    if (text != null && text.contains('\$')){
      var tmp = text.split('\$');
      if (tmp.length == 2 && tmp[1].length == Consts.keySize
          && utils.isValidUrl(tmp[0])
          && _passwordController.text == ""){
        _urlController.text = tmp[0];
        _passwordController.text = tmp[1];
        return true;
      }
    }

    return false;
  }

  _openQRCodeScanner(BuildContext context) async {
    _urlEnabled = false;
    _passwordEnabled = false;
    _releaseFocus();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DecryptQr()),
    );

    if (result != null && result.length == 2) {
      _urlController.text = result[0];
      _passwordController.text = result[1];
    }

    _urlEnabled = true;
    _passwordEnabled = true;
  }

  void _releaseFocus(){
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _openProgressBar(BuildContext context) async {
    _urlEnabled = false;
    _passwordEnabled = false;
    final String url = _urlController.text;
    final String password = _passwordController.text;


    _releaseFocus();
    await Navigator.push(
      context,
      MaterialPageRoute(
          settings: RouteSettings(name: "/decryptMetadata", isInitialRoute: false),
          builder: (context) => DecryptMetadata(url, password)),
    );

    _urlEnabled = true;
    _passwordEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text(Strings.Receive),
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
          width: utils.screenWidth(context),
          alignment: Alignment.center,
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
                              enabled: _urlEnabled,
                              controller: _urlController,
                              validator: _urlValidator,
                              icon: Icon(Icons.cloud_download),
                              hint: Strings.decryptUrlTextField,
                              autofocus: true,
                              onChanged: _checkForUrlAndPassword,
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: CustomTextField(
                              enabled: _passwordEnabled,
                              controller: _passwordController,
                              obsecure: true,
                              validator: _passwordValidator,
                              hint: Strings.decryptPasswordTextField,
                              icon: Icon(Icons.lock),
                              autofocus: false,
                            )),
                        Padding(
                          padding: EdgeInsets.only(
                              right: 40, left: 40, top: 20, bottom: 20),
                          child: OutlineButton(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              hoverColor: Theme.of(context).colorScheme.primary,
                              textColor: Theme.of(context).colorScheme.primary,
                              onPressed: _submit,
                              //icon: Icon(
                              //  Icons.cloud_upload,
                              //),
                              child: Text(Strings.decryptReceiveButton,
                                  style: Theme.of(context).accentTextTheme.title),
                            ),
                          ),
                      ]))),
        )));
  }
}
