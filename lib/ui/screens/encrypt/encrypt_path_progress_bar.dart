import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:secure_upload/ui/custom/progress_indicator.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_final.dart';
import 'dart:isolate';
import 'dart:async';

class EncryptProgress extends StatefulWidget {
  final List<String> files;

  EncryptProgress({@required this.files});

  _EncryptProgressState createState() =>
      _EncryptProgressState(files: files);
}

class _EncryptProgressState extends State<EncryptProgress> {
  final List<String> files;

  Isolate _isolate;
  double _progress = 0.0;
  String _progressString = "0%";

  _EncryptProgressState({this.files}) {
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

      if (_progress == 1.0){
        _isolate.kill();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FinalEncrypt(
                    "dropbox.com/asdjio1231", "password1111117890123890127301270371203790127390127903120937890")));
      }
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

  // TODO start encryption and upload
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
          color: Theme.of(context).primaryColor,
          child: CircularPercentIndicator(
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
