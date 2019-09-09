import 'package:flutter/material.dart';

import '../../../data/utils.dart' as utils;
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
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(label, style: Theme.of(context).accentTextTheme.title),
              ),
            ),
          ),
        ),
      );
    });

    return entries;
  }

  Widget build(BuildContext context) {
    final appBar = AppBar(
      centerTitle: true,
      title: Text(Strings.shareSelectionTitle),
    );

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: 30,
                      right: 30,
                      top: (utils.screenHeight(context) -
                          utils.screenSafeAreaPadding(context) -
                          appBar.preferredSize.height) /
                          8,
                      bottom: 50),
                  child: Text(
                    Strings.shareSelectionInfo,
                    style: Theme.of(context).textTheme.body1,
                  ),
                ),
                Column( children: _createShareOptionList(context),),
        ]
        ),
      ),
    );
  }
}
