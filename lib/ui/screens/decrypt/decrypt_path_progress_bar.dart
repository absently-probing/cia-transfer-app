import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

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
import 'decrypt_path_show_files.dart';


class IsolateDownloadData {
  final double progressStart;
  final double progressEnd;
  final String url;
  final String destination;
  final int size;

  IsolateDownloadData(this.progressStart, this.progressEnd, this.url, this.destination, this.size);
}

class IsolateDecryptData {
  final double progressStart;
  final double progressEnd;
  final String file;
  final String password;
  final String destinationFile;

  IsolateDecryptData(this.progressStart, this.progressEnd, this.file, this.password, this.destinationFile);
}

class IsolateExtractData {
  final double progressStart;
  final double progressEnd;
  final String file;
  final String destination;

  IsolateExtractData(this.progressStart, this.progressEnd, this.file, this.destination);
}

class DecryptProgress extends StatefulWidget {
  final String url;
  final String password;
  final int size;
  final List<String> expectedFiles;

  DecryptProgress({@required this.url, @required this.password, @required this.size, @required this.expectedFiles});

  _DecryptProgressState createState() =>
      _DecryptProgressState(url: url, password: password, size: size, expectedFiles: expectedFiles);
}

class _DecryptProgressState extends State<DecryptProgress> {
  final String url;
  final String password;
  final int size;
  final List<String> expectedFiles;

  Isolate _downloadIsolate;
  Isolate _decryptIsolate;
  Isolate _extractIsolate;

  ReceivePort _downloadReceive = ReceivePort();
  ReceivePort _decryptReceive = ReceivePort();
  ReceivePort _extractReceive = ReceivePort();

  bool _decryptStarted = false;
  bool _extractStarted = false;

  double _progress = 0.0;
  String _progressString = "0%";
  String _step = Strings.decryptProgressTextDownload;

  String _filename;
  String _docPath;
  String _tmpPath; // = (await getTemporaryDirectory()).path;
  String _tmpDownloadFile; // = path+'/'+filename;
  String _persistentArchive;

  List<String> _files;

  _DecryptProgressState({this.url, this.password, this.size, this.expectedFiles}) {
    start();
  }

  void dispose(){
    _downloadIsolate.kill(priority: Isolate.immediate);

    if (_decryptStarted){
      _decryptIsolate.kill(priority: Isolate.immediate);
    }

    if (_extractStarted){
      _extractIsolate.kill(priority: Isolate.immediate);
    }

    _downloadReceive.close();
    _decryptReceive.close();
    _extractReceive.close();
    super.dispose();
  }

  void start() async {
    _filename = Consts.decryptEncFile;
    _tmpPath = (await getTemporaryDirectory()).path;
    _docPath = (await getExternalStorageDirectory()).path;
    _tmpDownloadFile = _tmpPath+'/'+_filename;
    _persistentArchive = _docPath+'/'+Consts.decryptZipFile;
    _downloadIsolate = await Isolate.spawn(downloadFile,
        IsolateInitMessage<IsolateDownloadData>(
            _downloadReceive.sendPort,
            IsolateDownloadData(0.0, 0.6,url, _tmpDownloadFile, size)));

    _downloadReceive.listen((data) {
      _communicateDownload(data);
    });
  }

  // check if expected files (metadata) matches archive files
  bool validFiles(){
    bool valid = true;
    Map<String, int> test = {};
    for (String file in expectedFiles){
      if (test.containsKey(file)){
        test[file] = test[file] + 1;
      } else {
        test[file] = 1;
      }
    }

    for (String file in _files){
      var filename = p.basename(file);
      if (!test.containsKey(filename)){
        valid = false;
      } else {
        test[filename] = test[filename] - 1;
        if (test[filename] < 0){
          valid = false;
        }
      }
    }

    return valid;
  }

  void _communicateDownload(IsolateMessage<String, List<dynamic>> message) async {
    _updateProgress(message.progress);
    if(message.finished) {
      _downloadIsolate.kill();
      _step = Strings.decryptProgressTextDecrypt;
      _decryptIsolate = await Isolate.spawn(decryptFile,
          IsolateInitMessage<IsolateDecryptData>(
              _decryptReceive.sendPort,
              IsolateDecryptData(0.6, 0.9,_tmpDownloadFile, password, _persistentArchive)));

      _decryptReceive.listen((data) {
        _communicateDecrypt(data);
      });
    }
  }

  void _communicateDecrypt(IsolateMessage<String, List<dynamic>> message) async {
    _updateProgress(message.progress);
    if(message.finished) {
      _decryptIsolate.kill();
      _step = Strings.decryptProgressTextExtract;

      try {
        Directory(_docPath + '/' + Consts.decryptExtractDir).deleteSync(
            recursive: true);
      } catch (e) {}

      Directory(_docPath +'/'+Consts.decryptExtractDir).createSync(recursive: true);
      File(_tmpDownloadFile).deleteSync();
      _extractIsolate = await Isolate.spawn(extractFile,
          IsolateInitMessage<IsolateExtractData>(
              _extractReceive.sendPort, IsolateExtractData(
              0.9,
              1.0,
              _persistentArchive,
              _docPath +'/'+Consts.decryptExtractDir)));

      _extractReceive.listen((data) {
        _communcateExtract(data);
      });
    }
  }

  void _communcateExtract(IsolateMessage<String, List<dynamic>> message) async {
    _updateProgress(message.progress);
    if (message.finished){
      _extractIsolate.kill();
      File(_persistentArchive).deleteSync();
      _files = message.data;

      //TODO error handling expected file list doesn't match files extracted
      if (!validFiles()){

      } else {
        Navigator.of(context).pop();

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DecryptShowFiles(_files)));
      }
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
    var output = file.openSync(mode: FileMode.write);
    var allBytes = message.data.size;
    var writtenBytes = 0;
    ProgressOject progress = ProgressOject(message.sendPort, message.data.progressStart, message.data.progressEnd);
    response.listen((List event) {
      writtenBytes = writtenBytes + event.length;
      if (writtenBytes > allBytes){
        throw FormatException("wrong size");
      }

      output.writeFromSync(event);
      progress.progress(writtenBytes, allBytes, false);
    }, onDone: () {
      output.closeSync();
      message.sendPort.send(IsolateMessage<String, List<dynamic>>(message.data.progressEnd, true, false, null, null));
    }, onError: (e) {
      output.closeSync();
      message.sendPort.send(IsolateMessage<String, List<dynamic>>(0.0, false, true, e.toString(), null));
    });
  }

  static void decryptFile(IsolateInitMessage<IsolateDecryptData> message) async {
    try {
      // check if libsodium is supported for platform
      if (!Libsodium.supported()) {
        throw FormatException("Libsodium not supported");
      }

      // start decryption
      File sourceFile = File(message.data.file);
      File targetFile = File(message.data.destinationFile);

      ProgressOject progress = ProgressOject(message.sendPort, message.data.progressStart, message.data.progressEnd);
      Filecrypt encFile = Filecrypt(base64.decode(message.data.password));
      encFile.init(sourceFile, CryptoMode.dec);
      bool success = encFile.writeIntoFile(
          targetFile, callback: progress.progress);

      print("finished decryption");
      if (!success) {
        message.sendPort.send(IsolateMessage<String, List<dynamic>>(0.0, false, true, "Decryption failed", null));
      } else {
        message.sendPort.send(
            IsolateMessage<String, List<dynamic>>(0.0, true, false, null, null));
      }
    } catch (e){
      print(e.toString());
      message.sendPort.send(IsolateMessage<String, List<dynamic>>(0.0, false, true, "File error", null));
    }
  }

  static void extractFile(IsolateInitMessage<IsolateExtractData> message) async {
    try {
      File source = File(message.data.file);
      var content = source.readAsBytesSync();
      Archive archive = ZipDecoder().decodeBytes(content);

      ProgressOject progress = ProgressOject(message.sendPort, message.data.progressStart, message.data.progressEnd);
      var numberOfFiles = archive.length;
      int i = 0;
      List<String> files = [];
      for (ArchiveFile file in archive){
        String filename = file.name;
        if (file.isFile) {
          List<int> data = file.content;
          File(message.data.destination+'/'+ filename)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(message.data.destination+'/'+ filename)
            ..create(recursive: true);
        }

        i++;
        progress.progress(i, numberOfFiles, false);
        if (file.isFile) {
          files.add(message.data.destination+'/'+ filename);
        }
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(message.data.progressEnd, true, false, null, files));
    } catch (e){
      print(e.toString());
      message.sendPort.send(IsolateMessage<String, List<dynamic>>(0.0, false, true, "Extraction failed", null));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding:
                EdgeInsets.only(left: 20, right: 20, bottom: 50, top: 50),
                child: Text(
                  _step,
                  style: Theme.of(context).textTheme.headline,
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
