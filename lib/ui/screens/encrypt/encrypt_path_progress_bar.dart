import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secure_upload/backend/cloud/google/cloudClient.dart';
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:secure_upload/ui/custom/progress_indicator.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_final.dart';
import 'dart:isolate';
import 'dart:async';

class EncryptProgress extends StatefulWidget {
  final List<String> files;
  final CloudClient cloudClient;

  EncryptProgress({@required this.files, @required this.cloudClient});

  _EncryptProgressState createState() =>
      _EncryptProgressState(files: files, cloudClient: cloudClient);
}

class _EncryptProgressState extends State<EncryptProgress> {
  final List<String> files;
  final CloudClient cloudClient;

  Isolate _isolate;
  double _progress = 0.0;
  String _progressString = "0%";

  _EncryptProgressState({this.files, this.cloudClient}) {
    start();
    // TODO: real encryption here or in start()
    /*

    // TODO: is this needed?
    // Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    var localFile = File("/storage/emulated/0/Download/flower.jpg");
    var fileID = await client.createFile("myupload", localFile);
     */
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
