import 'package:flutter/material.dart';

class DecryptShowFiles extends StatefulWidget {
  final List<String> list;
  DecryptShowFiles(this.list, {Key key}) : super(key: key);

  @override
  _DecryptShowFiles createState() => _DecryptShowFiles(list);
}

class _DecryptShowFiles extends State<DecryptShowFiles> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _stateKey = GlobalKey<FormState>();
  final List<String> files;

  _DecryptShowFiles(this.files);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

      ),
    );
  }
}