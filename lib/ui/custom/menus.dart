import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:secure_upload/data/strings.dart';

class MainContextMenu extends StatelessWidget {
  final void Function(String, BuildContext) _callback;

  MainContextMenu(this._callback);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 10),
      onSelected: (String result) {
        _callback(result, context);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
          value: Strings.mainContextMenuSettings,
          child: Text(Strings.mainContextMenuSettings),
        ),

        // TODO: remove from production code, only for testing
        const PopupMenuDivider(height: 32),
        const PopupMenuItem<String>(
          value: "TESTING",
          child: Text("TESTING"),
        ),
        const PopupMenuItem<String>(
          value: Strings.mainContextMenuOnboarding,
          child: Text(Strings.mainContextMenuOnboarding),
        ),
        const PopupMenuItem<String>(
          value: Strings.shareSelectionTitle,
          child: Text("share selction screen"),
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
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
            ]);
  }
}
