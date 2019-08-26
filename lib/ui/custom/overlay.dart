import 'package:flutter/material.dart';


class CustomOverlay extends StatelessWidget {
  final Widget child;

  CustomOverlay({this.child});

  Widget build(BuildContext context) {
    return Dialog(
      child: this.child,
    );
  }
}