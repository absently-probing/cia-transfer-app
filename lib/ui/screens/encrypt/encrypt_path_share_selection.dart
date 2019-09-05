import 'package:flutter/material.dart';
import '../../../data/strings.dart';
import '../../../data/global.dart' as globals;
import 'encrypt_path_share_qr.dart';
import 'encrypt_path_share_separate.dart';
import 'encrypt_path_share_together.dart';

class ShareSelection extends StatelessWidget {
  final String _url;
  final String _password;

  ShareSelection(this._url, this._password);

  List<Widget> _createShareOptionList(BuildContext context) {
    final shareOptions = {
      Strings.shareSeparateTitle: ShareSeparate(_url, _password),
      Strings.shareTogetherTitle: ShareTogether(_url, _password),
      Strings.shareQrTitle: ShareQr(_url, _password),
    };

    List<Widget> entries = List<Widget>();
    shareOptions.forEach((label, screen) {
      entries.add(
        Padding(
          padding: EdgeInsets.only(right: 40, left: 40, top: 20, bottom: 20),
          child: SizedBox(
            width: globals.rootButtonWidth(context),
            height: globals.rootButtonHeight(context),
            child: OutlineButton(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
              hoverColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen),
                );
              },
              child: Text(label, style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      );
    });

    return entries;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.shareSelectionTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          children: _createShareOptionList(context),
        )),
      ),
    );
  }
}
