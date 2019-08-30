import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secure_upload/data/strings.dart';
import 'package:secure_upload/data/constants.dart';
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:secure_upload/ui/custom/progress_indicator.dart';
import 'package:secure_upload/ui/screens/encrypt/encrypt_path_final.dart';
import 'package:secure_upload/backend/cloud/google/cloudClient.dart';
import 'package:secure_upload/backend/cloud/google/googleDriveClient.dart';
import 'package:secure_upload/backend/cloud/google/mobileStorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:secure_upload/backend/crypto/cryptapi/cryptapi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'dart:io';
import 'dart:isolate';
import 'dart:async';

class IsolateMessage {
  final List<String> files;
  final SendPort sendPort;
  final Directory appDir;

  IsolateMessage(this.files, this.sendPort, this.appDir);
}

class ProgressOject {
  final SendPort sendPort;
  double _start;
  double _end;

  ProgressOject(this.sendPort, startValue, endValue){
    double checkStart = startValue;
    double checkEnd = endValue;
    if (checkStart < 0.0){
      checkStart = 0.0;
    }

    if (checkEnd > 1.0){
      checkEnd = 1.0;
    }

    if (checkStart >= checkEnd){
      checkStart = 0.0;
      checkEnd = 1.0;
    }

    _start = checkStart;
    _end = checkEnd;
  }

  void progress(int status, int all, bool finished) {
    double progress = _start + (status / (all * (_end - _start)));

    if (progress >= 1.0 && !finished){
      progress = 0.99;
    }

    sendPort.send(progress);
  }
}

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
    ReceivePort listenPort= ReceivePort(); //port for this main isolate to receive messages.
    Directory appDocDir = await getApplicationDocumentsDirectory();
    _isolate = await Isolate.spawn(runTimer, IsolateMessage(files, listenPort.sendPort, appDocDir));
    listenPort.listen((data) {

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
  static void runTimer(IsolateMessage message) async {
    Storage storage = MobileStorage();
    //Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    CloudClient client = GoogleDriveClient(storage);
    //await client.authenticate(utils.openURL);

    // start encryption
    File sourceFile = null;
    File targetFile =  File(message.appDir.path + "/" + Consts.encryptTargetFile);

    if (message.files.length > 1){
      var encoder = ZipFileEncoder();
      encoder.create(Consts.encryptZipFile);
      for (String file in message.files){
        encoder.addFile(File(file));
      }

      encoder.close();
      sourceFile = File(Consts.encryptZipFile);
    } else {
      sourceFile = File(message.files[0]);
    }

    //var fileID = await client.createFile("myupload", localFile);
    ProgressOject progress = ProgressOject(message.sendPort, 0.0, 0.5);
    Filecrypt encFile = Filecrypt();
    encFile.init(sourceFile, CryptoMode.enc);
    bool success = encFile.writeIntoFile(targetFile, callback: progress.progress);
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
