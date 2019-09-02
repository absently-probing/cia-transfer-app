import 'package:flutter/material.dart';
import '../../../backend/cloud/cloudClient.dart';
import '../../../data/constants.dart';
import 'encrypt_path_progress_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'dart:isolate';
import 'dart:io';

class IsolateZipInitMessage {
  final List<String> files;
  final SendPort sendPort;
  final Directory appDir;

  IsolateZipInitMessage(this.files, this.sendPort, this.appDir);
}

class ZipProgress extends StatefulWidget {
  final List<String> files;
  final CloudProvider cloudProvider;

  ZipProgress({@required this.files, @required this.cloudProvider});

  _ZipProgressState createState() => _ZipProgressState(files, cloudProvider);
}

class _ZipProgressState extends State<ZipProgress> {
  final List<String> files;
  final CloudProvider cloudProvider;
  Isolate _isolate;

  _ZipProgressState(this.files, this.cloudProvider) {
    _startZip();
  }

  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    super.dispose();
  }

  void _startZip() async {
    ReceivePort listenPort =
        ReceivePort(); //port for this main isolate to receive messages.
    Directory appDocDir = await getApplicationDocumentsDirectory();
    _isolate = await Isolate.spawn(
        zip, IsolateZipInitMessage(files, listenPort.sendPort, appDocDir));
    listenPort.listen((data) {
      if (data == "") {
        //handle error;
      }

      // remove zip progress from navigation
      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EncryptProgress(file: data, cloudProvider: cloudProvider)));
    });
  }

  static void zip(IsolateZipInitMessage message) {
    try {
      var encoder = ZipFileEncoder();
      encoder.open(message.appDir.path + "/" + Consts.encryptZipFile);
      for (String file in message.files) {
        encoder.addFile(File(file));
      }

      encoder.close();

      message.sendPort.send(message.appDir.path + "/" + Consts.encryptZipFile);
    } catch (e) {
      print(e.toString());
      message.sendPort.send("");
    }
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      //onWillPop: () async => false,
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
      ),
    );
  }
}
