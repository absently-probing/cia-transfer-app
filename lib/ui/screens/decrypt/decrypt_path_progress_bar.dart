import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:secure_upload/ui/custom/progress_indicator.dart';
import 'dart:isolate';
import 'dart:async';

class DecryptProgress extends StatefulWidget {
  final String url;
  final String password;

  DecryptProgress({@required this.url, @required this.password});

  _DecryptProgressState createState() =>
      _DecryptProgressState(url: url, password: password);
}

class _DecryptProgressState extends State<DecryptProgress> {
  final String url;
  final String password;

  Isolate _isolate;
  double _progress = 0.0;
  String _progressString = "0%";

  _DecryptProgressState({this.url, this.password}) {
    start();
  }

  void dispose(){
    _isolate.kill();
    super.dispose();
  }

  void start() async {
    ReceivePort receivePort= ReceivePort(); //port for this main isolate to receive messages.
    _isolate = await Isolate.spawn(runTimer, receivePort.sendPort);
    receivePort.listen((data) {
      _updateProgress(data);
    });
  }

  void _updateProgress(double progress){
    setState(() {
      if (progress > _progress){
        _progress = progress;
      }

      if (_progress > 1.0){
        _progress = 1.0;
      }

        _progressString = "${(_progress * 100).toInt()}%";
    });
  }

  // TODO start download and decryption
  static void runTimer(SendPort sendPort) {
    double progress = 0.0;
    Timer.periodic(new Duration(seconds: 1), (Timer t) {
      progress = progress + 0.1;
      sendPort.send(progress);
    });
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        //onWillPop: () async => false,
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: CircularPercentIndicator(
            progressColor: Theme.of(context).colorScheme.primary,
            radius: utils.screenWidth(context) / 2,
            animation: true,
            animateFromLastPercent: true,
            lineWidth: 5.0,
            percent: _progress,
            center: Text(_progressString),
      ),
    ));
  }
}
