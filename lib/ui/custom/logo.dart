import 'package:flutter/material.dart';
import '../../data/global.dart' as globals;

abstract class Logo {
  List<Widget> draw(BuildContext context);
}

class SecureUploadLogoPrimary extends Logo {
  List<Widget> draw(BuildContext context) {
    return <Widget>[
      Container(
        child: Icon(
          Icons.cloud_queue,
          size: globals.cloudIcon(context),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      Container(
        child: Icon(
          Icons.lock_outline,
          size: globals.lockIcon(context),
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ];
  }
}

class SecureUploadLogoSecondary extends Logo {
  List<Widget> draw(BuildContext context) {
    return <Widget>[
      Container(
        child: Icon(
          Icons.cloud_queue,
          size: globals.cloudIcon(context),
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      Container(
        child: Icon(
          Icons.lock_outline,
          size: globals.lockIcon(context),
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ];
  }
}
