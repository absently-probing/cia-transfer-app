import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'dart:math';

import '../../../data/metadata.dart';

import '../../../data/path.dart';
import '../../../data/constants.dart';
import '../../../data/utils.dart' as utils;
import '../../../data/strings.dart';
import '../../../data/isolate_messages.dart';
import '../../../data/isolate_storage.dart';
import '../../../ui/custom/progress_indicator.dart';
import '../../../backend/cloud/cloudClient.dart';
import '../../../backend/storage/storage.dart';
import '../../../backend/storage/mobileStorage.dart';
import '../../../backend/crypto/cryptapi/cryptapi.dart';
import '../../../data/progress_object.dart';
import 'encrypt_path_share_selection.dart';

// zip isolate init data
class IsolateZipInitMessage {
  final List<String> files;
  final String appDir;

  IsolateZipInitMessage(this.files, this.appDir);
}

// encrypt isolate init data
class IsolateEncryptInitData {
  final String file;
  final String appDir;

  IsolateEncryptInitData(this.file, this.appDir);
}

// upload isolate init data
class IsolateUploadInitData {
  final String file;
  final SendPort send;
  final CloudProvider cloudProvider;

  IsolateUploadInitData(this.file, this.send, this.cloudProvider);
}

// metadata isolate init data
class IsolateEncMetadataInitData {
  final String appDir;
  final List<String> files;
  final String key;
  final String fileUrl;
  final String publicKey;
  final int size;

  IsolateEncMetadataInitData(
      this.appDir, this.files, this.key, this.fileUrl, this.size,
      {this.publicKey = ""});
}

class IsolateVoidFunctions {
  final IsolateCommunication comm;

  IsolateVoidFunctions(this.comm);

  openURL(String url) {
    comm.send(IsolateRequest<String>("url.openURL", url));
  }
}

class EncryptProgress extends StatefulWidget {
  final List<String> files;
  final CloudProvider cloudProvider;

  EncryptProgress({@required this.files, @required this.cloudProvider});

  _EncryptProgressState createState() =>
      _EncryptProgressState(files: files, cloudProvider: cloudProvider);
}

class _EncryptProgressState extends State<EncryptProgress> {
  final List<String> files;
  final CloudProvider cloudProvider;

  Isolate _isolateZip;
  Isolate _isolateEncrypt;
  Isolate _isolateUpload;
  Isolate _isolateEncMetadata;
  Isolate _isolateUploadMetadata;

  ReceivePort _receiveZip = ReceivePort();
  ReceivePort _receiveEncrypt = ReceivePort();
  ReceivePort _receiveUpload = ReceivePort();
  ReceivePort _receiveEncMetadata = ReceivePort();
  ReceivePort _receiveUploadMetadata = ReceivePort();

  ReceivePort _receiveStorage = ReceivePort();

  Storage storage = MobileStorage();
  IsolateCommunicationHandler _handler;

  String _step = Strings.encryptProgressTextZip;

  double _progress = 0.01;
  String _progressString = "1%";
  String _key;
  String _fileUrl;
  int _fileSize;

  bool _zipError = false;
  bool _encryptError = false;
  bool _uploadError = false;
  bool _metadataError = false;

  _EncryptProgressState({this.files, this.cloudProvider}) {
    startEncryptAndUpload();
  }

  void dispose() {
    _receiveZip.close();
    _receiveEncrypt.close();
    _receiveUpload.close();
    _receiveEncMetadata.close();
    _receiveUploadMetadata.close();
    _receiveStorage.close();

    super.dispose();
  }

  // start zip isolate
  void startEncryptAndUpload() async {
    _handler = IsolateCommunicationHandler(_receiveStorage, _handleRequest);

    _isolateZip = await Isolate.spawn(
        zip,
        IsolateInitMessage<IsolateZipInitMessage>(_receiveZip.sendPort,
            progressStart: 0.0,
            progressEnd: 0.1,
            data: IsolateZipInitMessage(files, Path.getDocDir())));
    _receiveZip.listen((data) {
      _communicateZip(data);
    });
  }

  void _communicateZip(IsolateMessage<String, List<dynamic>> message) async {
    if (message.error) {
      _zipError = true;
      _isolateZip.kill();
      _showErrorDialog(message.errorData);
    }

    if (!_zipError) {
      _updateProgress(message.progress);

      if (message.finished) {
        _isolateZip.kill();
        var _zipFile = message.data[0];
        _step = Strings.encryptProgressTextEncrypt;
        _isolateEncrypt = await Isolate.spawn(
            encrypt,
            IsolateInitMessage<IsolateEncryptInitData>(_receiveEncrypt.sendPort,
                progressStart: 0.1,
                progressEnd: 0.3,
                data: IsolateEncryptInitData(_zipFile, Path.getDocDir())));
        _receiveEncrypt.listen((data) {
          _communicateEncrypt(data);
        });
      }
    }
  }

  // ui thread communication with isolate encrypt process
  void _communicateEncrypt(
      IsolateMessage<String, List<dynamic>> message) async {
    if (message.error) {
      _encryptError = true;
      _isolateEncrypt.kill();
      _showErrorDialog(message.errorData);
    }

    if (!_encryptError) {
      _updateProgress(message.progress);

      if (message.finished) {
        _isolateEncrypt.kill();
        _key = message.data[0];
        _fileSize = message.data[1];
        _step = Strings.encryptProgressTextUpload;
        _isolateUpload = await Isolate.spawn(
            upload,
            IsolateInitMessage<IsolateUploadInitData>(_receiveUpload.sendPort,
                progressStart: 0.3,
                progressEnd: 0.9,
                data: IsolateUploadInitData(
                    Path.getDocDir() + "/" + Consts.encryptTargetFile,
                    _receiveStorage.sendPort,
                    cloudProvider)));
        _handler.start();
        _receiveUpload.listen((data) {
          _communicateUpload(data);
        });
      }
    }
  }

  // ui thread communication with isolate upload process
  void _communicateUpload(IsolateMessage<String, List<dynamic>> message) async {
    if (message.error) {
      _uploadError = true;
      _isolateUpload.kill();
      _showErrorDialog(message.errorData);
    }

    if (!_uploadError) {
      _updateProgress(message.progress);

      if (message.finished) {
        _fileUrl = message.data[0];
        _isolateUpload.kill();
        _step = Strings.encryptProgressTextMetadata;

        _isolateEncMetadata = await Isolate.spawn(
            encMetadata,
            IsolateInitMessage<IsolateEncMetadataInitData>(
                _receiveEncMetadata.sendPort,
                progressStart: 0.9,
                progressEnd: 0.95,
                data: IsolateEncMetadataInitData(
                    Path.getDocDir(), files, _key, _fileUrl, _fileSize)));
        _receiveEncMetadata.listen((data) {
          _communicateEncMetadata(data);
        });
      }
    }
  }

  void _communicateEncMetadata(
      IsolateMessage<String, List<dynamic>> message) async {
    if (message.error) {
      _metadataError = true;
      _isolateEncMetadata.kill();
      _showErrorDialog(message.errorData);
    }

    if (!_metadataError) {
      _updateProgress(message.progress);

      if (message.finished) {
        var file = message.data[0];
        _isolateEncMetadata.kill();
        _step = Strings.encryptProgressTextMetadataUpload;

        _isolateUploadMetadata = await Isolate.spawn(
            upload,
            IsolateInitMessage<IsolateUploadInitData>(
                _receiveUploadMetadata.sendPort,
                progressStart: 0.95,
                progressEnd: 1.0,
                data: IsolateUploadInitData(
                    file, _receiveStorage.sendPort, cloudProvider)));
        _receiveUploadMetadata.listen((data) {
          _communicateMetadataUpload(data);
        });
      }
    }
  }

  void _communicateMetadataUpload(
      IsolateMessage<String, List<dynamic>> message) async {
    if (message.error) {
      _uploadError = true;
      _isolateUploadMetadata.kill();
      _showErrorDialog(message.errorData);
    }

    if (!_uploadError) {
      _updateProgress(message.progress);

      if (message.finished) {
        var url = message.data[0];
        _isolateUploadMetadata.kill();

        Navigator.of(context).pop();

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ShareSelection(url, _key)));
      }
    }
  }

  // update progress bar
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

  // ui thread handles storage or url requests
  void _handleRequest(
      IsolateRequest request, IsolateCommunicationHandler handler) async {
    switch (request.method) {
      case ".":
        handler.setSend(request.data);
        break;
      case "storage.get":
        String value = await storage.get(request.data);
        handler.send(IsolateResponse<String>(value));
        break;
      case "storage.set":
        List<String> data = request.data;
        storage.set(data[0], data[1]);
        break;
      case "url.openURL":
        utils.openURL(request.data);
        break;
      default:
        throw FormatException("Unknown method ${request.method}");
    }
  }

  void _showErrorDialog(String error) {
    // TODO delete _fileurl
    if (_fileUrl != null) {}

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
                    context, ModalRoute.withName("/cloudSelection"));
              },
            )
          ],
        );
      },
    );
  }

  Future<bool> _cancelEncryptionAndUpload() async {
    if (_isolateZip != null) {
      _isolateZip.kill(priority: Isolate.immediate);
    }

    if (_isolateEncrypt != null) {
      _isolateEncrypt.kill(priority: Isolate.immediate);
    }

    if (_isolateUpload != null) {
      _isolateUpload.kill(priority: Isolate.immediate);
    }

    if (_isolateEncMetadata != null) {
      _isolateEncMetadata.kill(priority: Isolate.immediate);
    }

    if (_isolateUploadMetadata != null) {
      _isolateUploadMetadata.kill(priority: Isolate.immediate);
    }

    var uploadPath = Directory(Path.getDocDir() + "/" + Consts.encryptDir);
    if (uploadPath.existsSync()) {
      uploadPath.deleteSync(recursive: true);
    }

    // TODO delete _fileurl and metadata if exists

    return true;
  }

  // zip files before encryption
  static void zip(IsolateInitMessage<IsolateZipInitMessage> message) {
    var zipFullPath = message.data.appDir + "/" + Consts.encryptZipFile;
    try {
      var encoder = ZipFileEncoder();
      encoder.open(zipFullPath);
      ProgressOject progress = ProgressOject(
          message.sendPort, message.progressStart, message.progressEnd);
      var i = 0;
      for (String file in message.data.files) {
        encoder.addFile(File(file));
        i++;
        progress.progress(i, message.data.files.length, false);
      }

      encoder.close();

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          message.progressEnd,
          true,
          false,
          null,
          [message.data.appDir + "/" + Consts.encryptZipFile]));
    } catch (e) {
      // delete zip file, if exists
      var tmp = File(zipFullPath);
      if (tmp.existsSync()) {
        tmp.deleteSync();
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, "Unable to create zip archive", null));
    }
  }

  // isolate encryption
  static void encrypt(
      IsolateInitMessage<IsolateEncryptInitData> message) async {
    Filecrypt encFile;
    var encFileFullPath = message.data.appDir + "/" + Consts.encryptTargetFile;
    File sourceFile = File(message.data.file);
    File targetFile = File(encFileFullPath);

    try {
      // start encryption
      encFile = Filecrypt();
      ProgressOject progress = ProgressOject(
          message.sendPort, message.progressStart, message.progressEnd);
      encFile.init(sourceFile, CryptoMode.enc);
      bool success =
          encFile.writeIntoFile(targetFile, callback: progress.progress);
      var key = base64.encode(encFile.getKey());
      sourceFile.deleteSync();
      var size = targetFile.lengthSync();

      if (!success) {
        throw Exception("Encryption failed");
      } else {
        encFile.clear();
        message.sendPort.send(IsolateMessage<String, List<dynamic>>(
            message.progressEnd, true, false, null, [key, size]));

        key = "";
      }
    } catch (e) {
      if (encFile != null) {
        encFile.clear();
      }

      // clean up remove zip file and encrypted file
      if (sourceFile.existsSync()) {
        sourceFile.deleteSync();
      }

      if (targetFile.existsSync()) {
        targetFile.deleteSync();
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, "Unable to encrypt file(s)", null));
    }
  }

  // isolate upload
  static void upload(IsolateInitMessage<IsolateUploadInitData> message) async {
    File targetFile = File(message.data.file);
    IsolateCommunication comm = IsolateCommunication(message.data.send);
    Storage storage = IsolateStorage(comm);

    try {
      CloudClient client =
          await CloudClientFactory.create(message.data.cloudProvider, storage);
      if (!(await client.hasCredentials())) {
        throw CloudCredentialsException(
            cause: providerToString(message.data.cloudProvider));
      }

      ProgressOject progress = ProgressOject(
          message.sendPort, message.progressStart, message.progressEnd);
      var fileID = await client.createFile(
          Filecrypt.randomFilename(), targetFile,
          progress: progress.progress);
      await client.setAccessibility(fileID, true);
      var url = await client.getURL(fileID);
      targetFile.deleteSync();
      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          message.progressEnd, true, false, null, [url]));
    } on CloudCredentialsException catch (cc) {
      if (targetFile.existsSync()) {
        targetFile.deleteSync();
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, "Unable to log into " + cc.toString(), null));
    } catch (e) {
      if (targetFile.existsSync()) {
        targetFile.deleteSync();
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, "Upload failed", null));
    }
  }

  // isolate create encrypted metadata
  static void encMetadata(
      IsolateInitMessage<IsolateEncMetadataInitData> message) async {
    List<int> _rkey = base64.decode(message.data.key);
    int timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;

    List<String> filenames = [];
    for (String file in message.data.files) {
      filenames.add(p.basename(file));
    }

    FileMetadata meta = FileMetadata(
        filenames, message.data.size, timestamp, message.data.fileUrl,
        publicKey: message.data.publicKey);

    Filecrypt fcrypt;

    File sourceFile =
        File(message.data.appDir + "/" + Consts.encryptMetadataTmpFile);
    File targetFile =
        File(message.data.appDir + "/" + Consts.encryptMetadataFile);

    try {
      // encode to json and write into sourceFile
      fcrypt = Filecrypt(_rkey);
      List<int> content = utf8.encode(json.encode(meta));
      var rsource = sourceFile.openSync(mode: FileMode.writeOnly);
      rsource.writeFromSync(content);
      rsource.closeSync();

      // encrypt sourceFile
      ProgressOject progress = ProgressOject(
          message.sendPort, message.progressStart, message.progressEnd);
      fcrypt.init(sourceFile, CryptoMode.enc, Consts.subkeyIDMetadata);
      bool success =
          fcrypt.writeIntoFile(targetFile, callback: progress.progress);
      sourceFile.deleteSync();

      if (!success) {
        throw Exception("Encryption failed");
      } else {
        fcrypt.clear();

        message.sendPort.send(IsolateMessage<String, List<dynamic>>(
            message.progressEnd, true, false, null, [targetFile.path]));
      }

      _rkey = [];
    } catch (e) {
      if (fcrypt != null) {
        fcrypt.clear();
      }

      if (sourceFile.existsSync()) {
        sourceFile.deleteSync();
      }

      if (targetFile.existsSync()) {
        targetFile.deleteSync();
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, "Encrypting metadata failed", null));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: WillPopScope(
        onWillPop: _cancelEncryptionAndUpload,
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, bottom: 50, top: 50),
                child: Text(
                  _step,
                  textAlign: TextAlign.center,
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
