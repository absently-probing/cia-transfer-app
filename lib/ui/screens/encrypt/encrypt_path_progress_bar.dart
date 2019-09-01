import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
import 'dart:io';
import 'dart:isolate';

class IsolateEncryptInitMessage {
  final String file;
  final SendPort sendPort;
  final Directory appDir;

  IsolateEncryptInitMessage(this.file, this.sendPort, this.appDir);
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
    double progress = _start + (status / all) * (_end - _start);

    if (progress >= 1.0 && !finished){
      progress = 0.99;
    }

    sendPort.send(progress);
  }
}

class EncryptProgress extends StatefulWidget {
  final String file;

  EncryptProgress({@required this.file});

  _EncryptProgressState createState() =>
      _EncryptProgressState(file: file);
}

class _EncryptProgressState extends State<EncryptProgress> {
  final String file;

  Isolate _isolate;
  double _progress = 0.0;
  String _progressString = "0%";

  _EncryptProgressState({this.file}) {
    startEncryptAndUpload();
  }

  void dispose(){
    _isolate.kill(priority: Isolate.immediate);
    super.dispose();
  }

  void startEncryptAndUpload() async {
    ReceivePort listenPort = ReceivePort(); //port for this main isolate to receive messages.
    Directory appDocDir = await getApplicationDocumentsDirectory();
    _isolate = await Isolate.spawn(encryptAndUpload, IsolateEncryptInitMessage(file, listenPort.sendPort, appDocDir));
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
  static void encryptAndUpload(IsolateEncryptInitMessage message) async {
    // check if libsodium is supported for platform
    if (!Libsodium.supported()){
      throw FormatException("Libsodium not supported");
    }

    // start encryption
    File sourceFile = File(message.file);
    File targetFile =  File(message.appDir.path + "/" + Consts.encryptTargetFile);

    ProgressOject progress = ProgressOject(message.sendPort, 0.0, 0.5);
    Filecrypt encFile = Filecrypt();
    encFile.init(sourceFile, CryptoMode.enc);
    bool success = encFile.writeIntoFile(targetFile, callback: progress.progress);
    if (success){
      WidgetsFlutterBinding.ensureInitialized();
      Storage storage = MobileStorage();
      //Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      CloudClient client = GoogleDriveClient(storage);
      //await client.authenticate(utils.openURL);
      var fileID = await client.createFile("myupload", targetFile);
    }
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
