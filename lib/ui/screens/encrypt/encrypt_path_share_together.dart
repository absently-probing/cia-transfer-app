import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '../../../data/global.dart' as globals;
import '../../../data/strings.dart';
import '../../../data/utils.dart' as utils;

class ShareTogether extends StatefulWidget {
  final String _url;
  final String _password;

  ShareTogether(this._url, this._password);

  @override
  _ShareTogether createState() => _ShareTogether(_url, _password);
}

class _ShareTogether extends State<ShareTogether> {
  final String _url;
  final String _password;
  Color _buttonColor = Colors.grey;
  bool _shared = false;

  _ShareTogether(this._url, this._password);

  void _finishButton(BuildContext context) {
    if (_shared) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/root', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      centerTitle: true,
      title: Text(Strings.shareTogetherTitle),
    );

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: (utils.screenHeight(context) -
                            utils.screenSafeAreaPadding(context) -
                            appBar.preferredSize.height) /
                        8,
                    bottom: 20),
                child: Text(
                  Strings.shareTogetherInfo,
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(left: 40, right: 40, bottom: 30),
                  child: OutlineButton(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        Share.share(_url + '\n' + _password);
                        // delay color change a bit, so user does only see it when coming back
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {
                            _shared = true;
                            _buttonColor = Colors.green;
                          });
                        });
                      },
                      child: Text('Share', // TODO put in Strings
                          style: Theme.of(context).accentTextTheme.title),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  _finishButton(context);
                },
                child: Icon(Icons.check),
                backgroundColor: _buttonColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
