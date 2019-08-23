import 'package:flutter/material.dart';
import 'package:secure_upload/ui/widgets/custom_buttons.dart';
import 'package:secure_upload/data/strings.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  createState() => new WelcomeScreenState();
}

enum WhyFarther { cloud, sync, setting }

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Strings.appTitle),
        actions: <Widget>[
          PopupMenuButton<WhyFarther>(
            //onSelected: (WhyFarther result) { setState(() { _selection = result; }); },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<WhyFarther>>[
              const PopupMenuItem<WhyFarther>(
                value: WhyFarther.cloud,
                child: Text('Cloud Storage'),
              ),
              const PopupMenuItem<WhyFarther>(
                value: WhyFarther.sync,
                child: Text('Synchronization'),
              ),
              const PopupMenuItem<WhyFarther>(
                value: WhyFarther.setting,
                child: Text('Settings'),
              ),
            ],
          )
        ],
      ),
      body: new Column(
        //Change Column!!!!
        children: <Widget>[
          Text(
            'Welcome',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          //const SizedBox(height: 30,),
          Text('Hello'),
          new MainScreenButtons(),
        ],
      ),
    );
  }
}

class MainScreenButtons extends StatefulWidget {
  @override
  createState() => new MainScreenButtonsState();
}

/// This is the stateless widget that the main application instantiates.
class MainScreenButtonsState extends State<MainScreenButtons> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
            child: CustomFlatButton(
              title: "Encrypt",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Colors.white,
              onPressed: null,
              splashColor: Colors.black12,
              borderColor: Color.fromRGBO(212, 20, 15, 1.0),
              borderWidth: 0,
              color: Color.fromRGBO(212, 20, 15, 1.0),
            ),
          ),
          new Padding(
            padding: new EdgeInsets.all(10.0),
            child: const RaisedButton(
              onPressed: null,
              child: const Text('Encryption not available',
                  style: TextStyle(fontSize: 20)),
            ),
          ),
          new Padding(
            padding: EdgeInsets.all(10.0),
            child: RaisedButton(
              onPressed: () {},
              child: const Text('Decrypt', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}
