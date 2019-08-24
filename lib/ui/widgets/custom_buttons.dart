import 'package:flutter/material.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/ui/screens/my_walkthrough_screen.dart';

class CustomFlatButton extends StatelessWidget {
  final String title;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onPressed;
  final Color color;
  final Color splashColor;
  final Color borderColor;
  final double borderWidth;

  CustomFlatButton(
      {this.title,
      this.textColor,
      this.fontSize,
      this.fontWeight,
      this.onPressed,
      this.color,
      this.splashColor,
      this.borderColor,
      this.borderWidth});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      color: color,
      splashColor: splashColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          title,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            decoration: TextDecoration.none,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: "OpenSans",
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
        side: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      ),
    );
  }
}

class CloudStorageProvider{
  int id;
  String name;

  CloudStorageProvider(
    this.id,
    this.name,
  );

  static List<CloudStorageProvider> getProvider(){
    return <CloudStorageProvider>[
      CloudStorageProvider(1, 'No Cloud Storage'),
      CloudStorageProvider(4, 'Dropbox'),
      CloudStorageProvider(2, 'OneDrive'),
      CloudStorageProvider(3, 'GoogleDrive'),
    ];
  }

}

class MyDropdownMenu extends StatefulWidget {
  MyDropdownMenu({Key key}) : super(key: key);

  @override
  _MyDropdownMenuState createState() => _MyDropdownMenuState();
}

class _MyDropdownMenuState extends State<MyDropdownMenu> {
  List<CloudStorageProvider> _cloudStorageProvider = CloudStorageProvider.getProvider();

  List<DropdownMenuItem<CloudStorageProvider>> _dropdownMenuItems;

  CloudStorageProvider _selectedProvider;
  String _sProvider = null;

  @override
  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_cloudStorageProvider);
    _selectedProvider = _dropdownMenuItems[0].value;
    super.initState();
  }


  List<DropdownMenuItem<CloudStorageProvider>>  buildDropdownMenuItems(List providers) {
    List<DropdownMenuItem<CloudStorageProvider>> items = List();
    for (CloudStorageProvider provider in providers){
      items.add(
        DropdownMenuItem(
          value: provider,
          child: Text(provider.name,
          style: new TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
            fontFamily: Strings.titleTextFont,
            fontWeight: FontWeight.w700,
            fontSize: 15.0,
          ),
        ),
        ),
      );
    }
    return items;
  }

  onChangeDropdownMenuItem(CloudStorageProvider selectedProvider){
    setState(() {
      _selectedProvider = selectedProvider;
      selectedProvider.name == 'No Cloud Storage'
          ? _sProvider = null
          : _sProvider = selectedProvider.name;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: new Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Theme.of(context).primaryColor
          ),
        child: DropdownButton(
          value: _selectedProvider,
          items: _dropdownMenuItems,
          onChanged: onChangeDropdownMenuItem,
        ),
      ),
    );
  }
}

class SelectCloudWithButton extends StatefulWidget {
  final void Function(BuildContext context, String provider) _callback;

  SelectCloudWithButton(this._callback, {Key key}) : super(key: key);

  @override
  _SelectCloudWithButton createState() => _SelectCloudWithButton(_callback);
}

class _SelectCloudWithButton extends State<SelectCloudWithButton> {
  final void Function(BuildContext context, String provider) _callback;
  String _sButtonTitle = Strings.onboardingSkip;
  List<CloudStorageProvider> _cloudStorageProvider = CloudStorageProvider.getProvider();

  List<DropdownMenuItem<CloudStorageProvider>> _dropdownMenuItems;

  CloudStorageProvider _selectedProvider;
  String _sProvider = null;

  _SelectCloudWithButton(this._callback);

  @override
  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_cloudStorageProvider);
    _selectedProvider = _dropdownMenuItems[0].value;
    _sButtonTitle = Strings.onboardingSkip;
    super.initState();
  }


  List<DropdownMenuItem<CloudStorageProvider>>  buildDropdownMenuItems(List providers) {
    List<DropdownMenuItem<CloudStorageProvider>> items = List();
    for (CloudStorageProvider provider in providers){
      items.add(
        DropdownMenuItem(
          value: provider,
          child: Text(provider.name,
            style: new TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
              fontFamily: Strings.titleTextFont,
              fontWeight: FontWeight.w700,
              fontSize: 15.0,
            ),
          ),
        ),
      );
    }
    return items;
  }

  onChangeDropdownMenuItem(CloudStorageProvider selectedProvider){
    setState(() {
      _selectedProvider = selectedProvider;
      selectedProvider.name == 'No Cloud Storage'
          ? _sProvider = null
          : _sProvider = selectedProvider.name;
      _sButtonTitle = _selectedProvider.name == 'No Cloud Storage'
          ? Strings.onboardingSkip
          : Strings.onboardingLogin;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: new Theme(
        data: Theme.of(context).copyWith(
            canvasColor: Theme.of(context).primaryColor
        ),
        child: new Column(
        children: <Widget>[
        new DropdownButton(
          value: _selectedProvider,
          items: _dropdownMenuItems,
          onChanged: onChangeDropdownMenuItem,
        ),
          new Padding(
            padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: new CustomFlatButton(
              title: _sButtonTitle,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: Colors.white,
              onPressed: (){
                _callback(context, _sProvider);
              },
              splashColor: Colors.black12,
              borderColor: Colors.white,
              borderWidth: 3.00,
              color: Colors.blueGrey,
            ),
          ),
        ]
        )
      ),
    );
  }
}

enum WhyFarther { onBoarding, cloud, sync, setting}





class MyPopupMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
      new PopupMenuButton<WhyFarther>(
          onSelected: (WhyFarther result) { if (result == WhyFarther.onBoarding){Navigator.push(
context, MaterialPageRoute(builder: (context) => MyWalkthroughScreen()),);
          }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<WhyFarther>>[
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.onBoarding,
              child: Text('OnBoarding'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.cloud,
              child: Text('Cloud Storage'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.sync,
              child: Text('Synchronization'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.setting,
              child: Text('Settings'),
            ),
          ],
        );
  }
}
