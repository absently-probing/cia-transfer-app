import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SecondEncrypt extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: new Text("Upload Complete"),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            // TODO: make this pretty and not a dirty hack
            new Text(''),
            new Text(''),
            new Text(''),
            new Text('Share the info'),
            new Text(''),
            new InkWell(
              child: new Text('dropbox link'),
              onTap: () => launch('https://flutter.dev'),
            ),
            new Text(''),
            new Text('Password: njk21jj'),
            new Text(''),
            QrImage(
              data: "1234567890",
              version: QrVersions.auto,
              size: 200.0,
            ),
            Spacer(),
            new Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: new Align(
                  alignment: Alignment.bottomRight,
                  child: new FloatingActionButton (
                    // TODO: when pushing this button reset history stack
                    onPressed: (){
                      Navigator.of(context).pushNamedAndRemoveUntil('/root',
                            (Route<dynamic> route) => false);
                      },
                    child: Icon(Icons.thumb_up),
                    backgroundColor: Colors.green,
                  ),
              ),
            ),
          ]
        )
      ),
    );
  }
}
