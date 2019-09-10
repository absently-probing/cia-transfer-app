import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:isolate';

import '../../../data/path.dart';
import '../../../data/constants.dart';
import '../../../data/utils.dart' as utils;
import '../../../data/progress_object.dart';
import '../../custom/progress_indicator.dart';
import '../../../data/isolate_messages.dart';
import '../../../backend/crypto/cryptapi/cryptapi.dart';
import '../../../data/strings.dart';
import 'decrypt_path_show_files.dart';

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

class IsolateExtractData {
  final String file;
  final String destination;

  IsolateExtractData(this.file, this.destination);
}

class DecryptProgress extends StatefulWidget {
  final String url;
  final String password;
  final int size;
  final List<String> expectedFiles;

  DecryptProgress(
      {@required this.url,
      @required this.password,
      @required this.size,
      @required this.expectedFiles});

  _DecryptProgressState createState() => _DecryptProgressState(
      url: url, password: password, size: size, expectedFiles: expectedFiles);
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

  double _progress = 0.0;
  String _progressString = "0%";
  String _step = Strings.decryptProgressTextDownload;

  String _tmpDownloadFile; // = path+'/'+filename;
  String _persistentArchive;
  String _extractPath;

  bool _downloadError = false;
  bool _decryptError = false;
  bool _extractError = false;

  List<String> _files;

  _DecryptProgressState(
      {this.url, this.password, this.size, this.expectedFiles}) {
    start();
  }

  void dispose() {
    _downloadReceive.close();
    _decryptReceive.close();
    _extractReceive.close();
    super.dispose();
  }

  void start() async {
    _extractPath = Path.getDocDir() + '/' + Consts.decryptExtractDir;
    _tmpDownloadFile = Path.getTmpDir() + '/' + Consts.decryptEncFile;
    _persistentArchive = Path.getDocDir() + '/' + Consts.decryptZipFile;
    _downloadIsolate = await Isolate.spawn(
        downloadFile,
        IsolateInitMessage<IsolateDownloadData>(_downloadReceive.sendPort,
            progressStart: 0.0,
            progressEnd: 0.6,
            data: IsolateDownloadData(url, _tmpDownloadFile, size)));

    _downloadReceive.listen((data) {
      _communicateDownload(data);
    });
  }

  // check if expected files (metadata) matches archive files
  bool validFiles() {
    bool valid = true;
    Map<String, int> test = {};
    for (String file in expectedFiles) {
      if (test.containsKey(file)) {
        test[file] = test[file] + 1;
      } else {
        test[file] = 1;
      }
    }

    for (String file in _files) {
      var filename = p.basename(file);
      if (!test.containsKey(filename)) {
        valid = false;
      } else {
        test[filename] = test[filename] - 1;
        if (test[filename] < 0) {
          valid = false;
        }
      }
    }

    return valid;
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          content: Text(
            error,
            style: Theme.of(context).textTheme.title,
          ),
          actions: [
            FlatButton(
              child: Text("close"),
              onPressed: () async {
                Navigator.popUntil(
                    context, ModalRoute.withName("/decryptMetadata"));
              },
            )
          ],
        );
      },
    );
  }

  void _communicateDownload(
      IsolateMessage<String, List<dynamic>> message) async {
    if (message.error) {
      _downloadError = true;
      _downloadIsolate.kill();
      _showErrorDialog(message.errorData);
    }

    if (!_downloadError) {
      _updateProgress(message.progress);
      if (message.finished) {
        _downloadIsolate.kill();
        _step = Strings.decryptProgressTextDecrypt;
        _decryptIsolate = await Isolate.spawn(
            decryptFile,
            IsolateInitMessage<IsolateDecryptData>(_decryptReceive.sendPort,
                progressStart: 0.6,
                progressEnd: 0.9,
                data: IsolateDecryptData(
                    _tmpDownloadFile, password, _persistentArchive)));

        _decryptReceive.listen((data) {
          _communicateDecrypt(data);
        });
      }
    }
  }

  void _communicateDecrypt(
      IsolateMessage<String, List<dynamic>> message) async {
    if (message.error) {
      _decryptError = true;
      _decryptIsolate.kill();
      _showErrorDialog(message.errorData);
    }

    if (!_decryptError) {
      _updateProgress(message.progress);
      if (message.finished) {
        _decryptIsolate.kill();
        _step = Strings.decryptProgressTextExtract;

        File(_tmpDownloadFile).deleteSync();
        _extractIsolate = await Isolate.spawn(
            extractFile,
            IsolateInitMessage<IsolateExtractData>(_extractReceive.sendPort,
                progressStart: 0.9,
                progressEnd: 1.0,
                data: IsolateExtractData(_persistentArchive, _extractPath)));

        _extractReceive.listen((data) {
          _communcateExtract(data);
        });
      }
    }
  }

  void _communcateExtract(IsolateMessage<String, List<dynamic>> message) async {
    if (message.error) {
      _extractError = true;
      _extractIsolate.kill();
      _showErrorDialog(message.errorData);
    }

    if (!_extractError) {
      _updateProgress(message.progress);
      if (message.finished) {
        _extractIsolate.kill();
        File(_persistentArchive).deleteSync();
        _files = message.data;

        //TODO error handling expected file list doesn't match files extracted
        if (!validFiles()) {
          var extractDir = Directory(_extractPath);
          try {
            if (extractDir.existsSync()) {
              extractDir.deleteSync(recursive: true);
            }
          } catch (e) {}

          _showErrorDialog("Incorrect Metadata informations");
        } else {
          Navigator.of(context).pop();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DecryptShowFiles(_files, _extractPath + "/")));
        }
      }
    }
  }

  void _updateProgress(double progress) {
    setState(() {
      if (progress > _progress) {
        _progress = progress;
      }

      if (_progress > 1.0) {
        _progress = 1.0;
      }

      _progressString = "${(_progress * 100).toInt()}%";
    });
  }

  Future<bool> _cancelDownloadAndDecryption() async {
    if (_downloadIsolate != null) {
      _downloadIsolate.kill(priority: Isolate.immediate);
    }

    if (_decryptIsolate != null) {
      _decryptIsolate.kill(priority: Isolate.immediate);
    }

    if (_extractIsolate != null) {
      _extractIsolate.kill(priority: Isolate.immediate);
    }

    var decryptDir = Directory(Consts.decryptDir);

    if (decryptDir.existsSync()) {
      decryptDir.deleteSync(recursive: true);
    }

    return true;
  }

  static void downloadFile(
      IsolateInitMessage<IsolateDownloadData> message) async {
    String url = message.data.url;
    var file = File(message.data.destination);
    var error = false;

    try {
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      HttpClient client = HttpClient();
      var request = await client.getUrl(Uri.parse(url));
      var response = await request.close();

      var output = file.openSync(mode: FileMode.write);
      var allBytes = message.data.size;
      var writtenBytes = 0;
      ProgressOject progress = ProgressOject(
          message.sendPort, message.progressStart, message.progressEnd);
      response.listen((List event) {
        writtenBytes = writtenBytes + event.length;
        if (writtenBytes > allBytes) {
          throw FormatException("wrong size");
        }

        output.writeFromSync(event);
        progress.progress(writtenBytes, allBytes, false);
      }, onDone: () {
        output.closeSync();

        if (error || writtenBytes != allBytes) {
          if (file.existsSync()) {
            file.deleteSync();
          }

          message.sendPort.send(IsolateMessage<String, List<dynamic>>(
              0.0, false, true, "Download failed", null));
        } else {
            message.sendPort.send(IsolateMessage<String, List<dynamic>>(
                message.progressEnd, true, false, null, null));
          }
      }, onError: (e) {
        error = true;
      });
    } catch (e) {
      if (file.existsSync()) {
        file.deleteSync();
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, "Download failed", null));
    }
  }

  static void decryptFile(
      IsolateInitMessage<IsolateDecryptData> message) async {
    File sourceFile = File(message.data.file);
    File targetFile = File(message.data.destinationFile);
    Filecrypt decFile;

    try {
      if (!targetFile.existsSync()){
        targetFile.createSync(recursive: true);
      }

      print("Start decryption");
      // start decryption
      ProgressOject progress = ProgressOject(
          message.sendPort, message.progressStart, message.progressEnd);
      decFile = Filecrypt(base64.decode(message.data.password));
      decFile.init(sourceFile, CryptoMode.dec);
      bool success =
          decFile.writeIntoFile(targetFile, callback: progress.progress);

      print("End decryption");
      if (!success) {
        throw Exception("Decryption failed");
      } else {
        decFile.clear();
        message.sendPort.send(IsolateMessage<String, List<dynamic>>(
            0.0, true, false, null, null));
      }
    } catch (e) {
      print(e.toString());
      if (decFile != null) {
        decFile.clear();
      }

      if (sourceFile.existsSync()) {
        sourceFile.deleteSync();
      }

      if (targetFile.existsSync()) {
        targetFile.deleteSync();
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, "Decryption failed", null));
    }
  }

  static void extractFile(
      IsolateInitMessage<IsolateExtractData> message) async {
    File source = File(message.data.file);
    var extractDir = Directory(message.data.destination);

    try {
      if (extractDir.existsSync()) {
        extractDir.deleteSync(recursive: true);
      }

      extractDir.createSync(recursive: true);

      var content = source.readAsBytesSync();
      Archive archive = ZipDecoder().decodeBytes(content);

      ProgressOject progress = ProgressOject(
          message.sendPort, message.progressStart, message.progressEnd);
      var numberOfFiles = archive.length;
      int i = 0;
      List<String> files = [];
      for (ArchiveFile file in archive) {
        String filename = file.name;
        if (file.isFile) {
          List<int> data = file.content;
          File(message.data.destination + '/' + filename)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(message.data.destination + '/' + filename)
            ..create(recursive: true);
        }

        i++;
        progress.progress(i, numberOfFiles, false);
        if (file.isFile) {
          files.add(message.data.destination + '/' + filename);
        }
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          message.progressEnd, true, false, null, files));
    } catch (e) {
      if (source.existsSync()) {
        source.deleteSync();
      }

      if (extractDir.existsSync()) {
        extractDir.deleteSync(recursive: true);
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, "Extraction failed", null));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: WillPopScope(
        onWillPop: _cancelDownloadAndDecryption,
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
                  radius: min(utils.screenWidth(context) / 2,
                      utils.screenHeight(context) / 2),
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
      ),
    );
  }
}
