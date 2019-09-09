import 'package:flutter/material.dart';

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
  final _stateKey = GlobalKey<FormState>();

  var _urlEnabled = true;
  var _passwordEnabled = true;

  var _urlController = TextEditingController();
  var _passwordController = TextEditingController();

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
      MaterialPageRoute(builder: (context) => DecryptMetadata(url, password)),
    );

    _urlEnabled = true;
    _passwordEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              maxLength: Consts.keySize,
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
