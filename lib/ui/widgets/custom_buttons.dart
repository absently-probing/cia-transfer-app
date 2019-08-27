import 'package:flutter/material.dart';
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/ui/screens/my_walkthrough_screen.dart';

import 'dart:math';

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

class CloudStorageProvider {
  int id;
  String name;

  CloudStorageProvider(
    this.id,
    this.name,
  );

  static List<CloudStorageProvider> getProvider() {
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
  List<CloudStorageProvider> _cloudStorageProvider =
      CloudStorageProvider.getProvider();

  List<DropdownMenuItem<CloudStorageProvider>> _dropdownMenuItems;

  CloudStorageProvider _selectedProvider;
  String _sProvider = null;

  @override
  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_cloudStorageProvider);
    _selectedProvider = _dropdownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<CloudStorageProvider>> buildDropdownMenuItems(
      List providers) {
    List<DropdownMenuItem<CloudStorageProvider>> items = List();
    for (CloudStorageProvider provider in providers) {
      items.add(
        DropdownMenuItem(
          value: provider,
          child: Text(
            provider.name,
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

  onChangeDropdownMenuItem(CloudStorageProvider selectedProvider) {
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
        data: Theme.of(context)
            .copyWith(canvasColor: Theme.of(context).primaryColor),
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
  List<CloudStorageProvider> _cloudStorageProvider =
      CloudStorageProvider.getProvider();

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

  List<DropdownMenuItem<CloudStorageProvider>> buildDropdownMenuItems(
      List providers) {
    List<DropdownMenuItem<CloudStorageProvider>> items = List();
    for (CloudStorageProvider provider in providers) {
      items.add(
        DropdownMenuItem(
          value: provider,
          child: Text(
            provider.name,
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

  onChangeDropdownMenuItem(CloudStorageProvider selectedProvider) {
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
          data: Theme.of(context)
              .copyWith(canvasColor: Theme.of(context).primaryColor),
          child: new Column(children: <Widget>[
            new DropdownButton(
              value: _selectedProvider,
              items: _dropdownMenuItems,
              onChanged: onChangeDropdownMenuItem,
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: new CustomFlatButton(
                title: _sButtonTitle,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: Colors.white,
                onPressed: () {
                  _callback(context, _sProvider);
                },
                splashColor: Colors.black12,
                borderColor: Colors.white,
                borderWidth: 3.00,
                color: Colors.blueGrey,
              ),
            ),
          ])),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final Icon icon;
  final String hint;
  final bool obsecure;
  final FormFieldValidator<String> validator;
  final autofocus;
  final TextEditingController controller;
  final FocusNode focusNode;

  CustomTextField(
      {this.icon,
      this.hint,
      this.obsecure = false,
      this.validator,
      this.onSaved,
      this.autofocus = true,
      this.focusNode = null,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: new Theme(
        data: ThemeData(
          primaryColor: Colors.black,
          hintColor: Colors.black,
        ),
        child: TextFormField(
          focusNode: this.focusNode,
          onSaved: onSaved,
          validator: validator,
          autofocus: autofocus,
          obscureText: obsecure,
          controller: controller,
          style: TextStyle(
            fontSize: 20,
          ),
          decoration: InputDecoration(
              hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              hintText: hint,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  width: 2,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  width: 3,
                ),
              ),
              prefixIcon: Padding(
                child: IconTheme(
                  data: IconThemeData(color: Theme.of(context).buttonColor),
                  child: icon,
                ),
                padding: EdgeInsets.only(left: 30, right: 10),
              )),
        ),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  CustomText({this.text, this.icon, this.width, this.fontSize});

  final Icon icon;
  final String text;
  final double fontSize;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(children: [
        Container(
          child: icon,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.grey[300],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: SizedBox(
                width: min(width, (utils.screenWidth(context) - 140)),
                child: Text(text,
                    style: TextStyle(
                      fontSize: fontSize,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class MainContextMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new PopupMenuButton<String>(
      offset: Offset(0, 10),
      onSelected: (String result) {
        if (result == Strings.mainContextMenuOnboarding) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyWalkthroughScreen()),
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: Strings.mainContextMenuOnboarding,
          child: Text(Strings.mainContextMenuOnboarding),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: Strings.mainContextMenuCloudStorage,
          child: Text(Strings.mainContextMenuCloudStorage),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: Strings.mainContextMenuSync,
          child: Text(Strings.mainContextMenuSync),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: Strings.mainContextMneuSettings,
          child: Text(Strings.mainContextMneuSettings),
        ),
      ],
    );
  }
}

class EncryptShareMenu extends StatelessWidget {
  final void Function(String) callback;

  EncryptShareMenu(this.callback);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
        icon: Icon(Icons.share),
        offset: Offset(0, 10),
        onSelected: callback,
        itemBuilder: (BuildContext context) =>
        <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: Strings.encryptShareUrl,
            child: Text(Strings.encryptShareUrl),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: Strings.encryptSharePassword,
            child: Text(Strings.encryptSharePassword),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: Strings.encryptShareBoth,
            child: Text(Strings.encryptShareBoth),
          ),
        ]
    );
  }
}
