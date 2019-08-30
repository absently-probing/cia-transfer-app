import 'package:flutter/material.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/ui/custom/buttons.dart';

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
    _dropdownMenuItems = _buildDropdownMenuItems(_cloudStorageProvider);
    _selectedProvider = _dropdownMenuItems[0].value;
    _sButtonTitle = Strings.onboardingSkip;
    super.initState();
  }

  List<DropdownMenuItem<CloudStorageProvider>> _buildDropdownMenuItems(
      List providers) {
    List<DropdownMenuItem<CloudStorageProvider>> items = List();
    for (CloudStorageProvider provider in providers) {
      items.add(
        DropdownMenuItem(
          value: provider,
          child: Text(
            provider.name,
            style: TextStyle(
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

  _onChangeDropdownMenuItem(CloudStorageProvider selectedProvider) {
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
      child: Theme(
          data: Theme.of(context)
              .copyWith(canvasColor: Theme.of(context).primaryColor),
          child: Column(children: <Widget>[
            DropdownButton(
              value: _selectedProvider,
              items: _dropdownMenuItems,
              onChanged: _onChangeDropdownMenuItem,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: CustomFlatButton(
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
                color: Theme.of(context).primaryColor,
              ),
            ),
          ])),
    );
  }
}