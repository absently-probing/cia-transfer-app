import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:isolate';

import '../../../data/constants.dart';
import '../../../data/utils.dart' as utils;
import '../../../data/progress_object.dart';
import '../../custom/progress_indicator.dart';
import '../../../data/isolate_messages.dart';
import '../../../backend/crypto/cryptapi/cryptapi.dart';
import '../../../data/strings.dart';


class IsolateDownloadData {
  final String url;
  final String destination;
  final int size;

  IsolateDownloadData(this.url, this.destination, this.size);
}

class IsolateDecryptData {
  final String file;
  final String password;
  final String destinationFile;

  IsolateDecryptData(this.file, this.password, this.destinationFile);
}

class DecryptProgress extends StatefulWidget {
  final String url;
  final String password;
  final int size;

  DecryptProgress({@required this.url, @required this.password, @required this.size});

  _DecryptProgressState createState() =>
      _DecryptProgressState(url: url, password: password, size: size);
}

class _DecryptProgressState extends State<DecryptProgress> {
  final String url;
  final String password;
  final int size;

  Isolate _downloadIsolate;
  Isolate _decryptIsolate;
  double _progress = 0.0;
  String _progressString = "0%";
  String _step = Strings.decryptProgressTextDownload;

  String filename; // = 'secureUpload-'+Filecrypt.randomFilename();
  String path; // = (await getTemporaryDirectory()).path;
  String tmpDestination; // = path+'/'+filename;
  String persistentDestination;

  _DecryptProgressState({this.url, this.password, this.size}) {
    start();
  }

  void dispose(){
    _downloadIsolate.kill();
    super.dispose();
  }

  void start() async {
    ReceivePort receivePort= ReceivePort(); //port for this main isolate to receive messages.
    filename = Consts.decryptEncFile;
    path = (await getTemporaryDirectory()).path;
    tmpDestination = path+'/'+filename;
    persistentDestination = (await getExternalStorageDirectory()).path+'/'+Consts.decryptZipFile;
    _downloadIsolate = await Isolate.spawn(downloadFile, IsolateInitMessage<IsolateDownloadData>(receivePort.sendPort, IsolateDownloadData(url, tmpDestination, size)));
    receivePort.listen((data) {
      _communicateDownload(data);
    });



    //TODO: delete tmp-file
    //File(tmpDestination).deleteSync();
  }

  void _communicateDownload(IsolateMessage<String, List<dynamic>> message) async {
    _updateProgress(message.progress);
    if(message.finished) {
      _downloadIsolate.kill();
      ReceivePort receivePort= ReceivePort();
      _step = Strings.decryptProgressTextDecrypt;
      _decryptIsolate = await Isolate.spawn(decryptFile, IsolateInitMessage<IsolateDecryptData>(receivePort.sendPort, IsolateDecryptData(tmpDestination, password, persistentDestination)));
      receivePort.listen((data) {
        _communicateDecrypt(data);
      });
    }
  }

  void _communicateDecrypt(IsolateMessage<String, List<dynamic>> message) async {
    _updateProgress(message.progress);
    if(message.finished) {
      _decryptIsolate.kill();
      _step = Strings.decryptProgressTextExtract;
      File(tmpDestination).deleteSync();
    }
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

  static void downloadFile(IsolateInitMessage<IsolateDownloadData> message) async {
    String url = message.data.url;

    HttpClient client = HttpClient();
    var request = await  client.getUrl(Uri.parse(url));
    var response = await request.close();
    var tmpFile = message.data.destination;

    var file = File(tmpFile);
    //var sink = file.openWrite();
    var output = file.openSync(mode: FileMode.write);
    //var allBytes = await response.contentLength;//50000;//await response.length;
    var allBytes = message.data.size;
    var writtenBytes = 0;
    ProgressOject progress = ProgressOject(message.sendPort, 0.0, 0.5);
    response.listen((List event) {
      //var writtenBytesNew = writtenBytes+event.length;
      writtenBytes = writtenBytes + event.length;
      if (writtenBytes > allBytes){
        throw FormatException("wrong size");
      }

      output.writeFromSync(event);
      //sink.add(event);
      /*
      if(writtenBytesNew % 1024 != writtenBytes % 1024) {
        message.sendPort.send(IsolateMessage<String, String>(writtenBytesNew/(2*allBytes), false, false, null, null));
      }*/
      progress.progress(writtenBytes, allBytes, false);
      //writtenBytes = writtenBytesNew;
    }, onDone: () {
      //sink.close();
      output.closeSync();
      message.sendPort.send(IsolateMessage<String, List<dynamic>>(0.5, true, false, null, null));
    }, onError: (e) {
      //sink.close();
      output.closeSync();
      message.sendPort.send(IsolateMessage<String, List<dynamic>>(0.0, false, true, e.toString(), null));
    });
    //await Isolate.spawn(encrypt, IsolateInitMessage<IsolateEncryptInitData>(_receiveEncrypt.sendPort, IsolateEncryptInitData(file, _appDocDir)))
  }

  static void decryptFile(IsolateInitMessage<IsolateDecryptData> message) async {
    try {
      // check if libsodium is supported for platform
      if (!Libsodium.supported()) {
        throw FormatException("Libsodium not supported");
      }

      // start encryption
      File sourceFile = File(message.data.file);
      File targetFile = File(message.data.destinationFile);

      ProgressOject progress = ProgressOject(message.sendPort, 0.5, 1.0);
      Filecrypt encFile = Filecrypt(base64.decode(message.data.password));
      encFile.init(sourceFile, CryptoMode.dec);
      bool success = encFile.writeIntoFile(
          targetFile, callback: progress.progress);
      if (!success) {
        message.sendPort.send(IsolateMessage<String, List<dynamic>>(0.0, true, true, "Encryption failed", null));
      } else {
        message.sendPort.send(
            IsolateMessage<String, List<dynamic>>(0.0, true, false, null, null));
      }
    } catch (e){
      print(e.toString());
      message.sendPort.send(IsolateMessage<String, List<dynamic>>(0.0, true, true, "File error", null));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: WillPopScope(
        //onWillPop: () async => false,
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding:
                EdgeInsets.only(left: 20, right: 20, bottom: 50, top: 50),
                child: Text(
                  _step,
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontFamily: Strings.titleTextFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 20.0,
                  ),
                ),
              ),
              Container(
                child: CircularPercentIndicator(
                  progressColor: Theme.of(context).colorScheme.primary,
                  radius: min(utils.screenWidth(context) / 2, utils.screenHeight(context) / 2),
                  animation: true,
                  animateFromLastPercent: true,
                  lineWidth: 5.0,
                  percent: _progress,
                  center: Text(_progressString),
                ),
              )
            ]),
          ),
        ),
      ),);
  }
}
