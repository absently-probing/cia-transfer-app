// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String app_name = "Secure--Upload";
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(app_name),
        ),
        body: Column(
          children: <Widget>[
            Text(
                'Welcome',
                style:
                  TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30,),
            Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus efficitur sagittis massa, eu vehicula ipsum ullamcorper porttitor. Suspendisse magna nunc, euismod sed libero eget, consequat malesuada nibh. In mollis eros vel consequat elementum. Morbi ultricies facilisis nisl a dictum. Suspendisse potenti. Sed viverra non nisi in imperdiet. Donec mi odio, vestibulum eget vulputate vel, vestibulum sit amet massa. Ut ac enim id lectus efficitur tincidunt. Curabitur a blandit quam. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Quisque maximus orci at odio efficitur bibendum. Cras malesuada mattis eros vitae sodales. '),
            MyStatelessWidget(),
          ],
        )
      ),
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          minWidth: 250,
          height: 100,
        )
      ),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 75),
          const RaisedButton(
            onPressed: null,
            child: Text('Encryption not available', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(
              height: 50),
          RaisedButton(
            onPressed: () {},

            child: const Text('Decrypt', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}