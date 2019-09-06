import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'dart:math';

import '../../../data/metadata.dart';

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
  final SendPort sendPort;
  final Directory appDir;

  IsolateZipInitMessage(this.files, this.sendPort, this.appDir);
}

// encrypt isolate init data
class IsolateEncryptInitData {
  final double progressStart;
  final double progressEnd;
  final String file;
  final Directory appDir;

  IsolateEncryptInitData(this.progressStart, this.progressEnd,
      this.file, this.appDir);
}

// upload isolate init data
class IsolateUploadInitData {
  final double progressStart;
  final double progressEnd;
  final String file;
  final SendPort send;
  final CloudProvider cloudProvider;

  IsolateUploadInitData(this.progressStart, this.progressEnd,
      this.file, this.send, this.cloudProvider);
}

// metadata isolate init data
class IsolateEncMetadataInitData {
  final double progressStart;
  final double progressEnd;
  final Directory appDir;
  final List<String> files;
  final String key;
  final String fileUrl;
  final String publicKey;
  final int size;

  IsolateEncMetadataInitData(this.progressStart, this.progressEnd, this.appDir,
      this.files, this.key, this.fileUrl, this.size, {this.publicKey = ""});
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

  ReceivePort _receiveZip = ReceivePort();
  ReceivePort _receiveEncrypt = ReceivePort();
  ReceivePort _receiveUpload = ReceivePort();
  ReceivePort _receiveEncMetadata = ReceivePort();
  ReceivePort _receiveUploadMetadata = ReceivePort();

  ReceivePort _receiveStorage = ReceivePort();

  Storage storage = MobileStorage();
  IsolateCommunicationHandler _handler;

  String _step = Strings.encryptProgressTextZip;

  double _progress = 0.0;
  String _progressString = "0%";
  Directory _appDocDir;
  String _key;
  String _fileUrl;
  int _fileSize;

  bool _zipError = false;
  bool _encryptError = false;
  bool _uploadError = false;
  bool _metadataError = false;

  bool _encryptStarted = false;
  bool _uploadStarted = false;
  bool _encMetadataStarted = false;

  _EncryptProgressState({this.files, this.cloudProvider}) {
    startEncryptAndUpload();
  }

  void dispose() {
    _isolateZip.kill(priority: Isolate.immediate);

    if (_encryptStarted) {
      _isolateEncrypt.kill(priority: Isolate.immediate);
    }

    if (_uploadStarted) {
      _isolateUpload.kill(priority: Isolate.immediate);
    }

    if (_encMetadataStarted){
      _isolateEncMetadata.kill(priority: Isolate.immediate);
    }

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

    _appDocDir = await getApplicationDocumentsDirectory();
    _updateProgress(0.01);
    _isolateZip = await Isolate.spawn(
        zip, IsolateZipInitMessage(files, _receiveZip.sendPort, _appDocDir));
    _receiveZip.listen((data) async {
      if (data == "") {
        // TODO handle error (ui)
        _zipError = true;
      }

      if (!_zipError) {
        _encryptStarted = true;
        // remove zip progress from navigation
        _updateProgress(0.1);
        _step = Strings.encryptProgressTextEncrypt;
        _isolateEncrypt = await Isolate.spawn(
            encrypt,
            IsolateInitMessage<IsolateEncryptInitData>(_receiveEncrypt.sendPort,
                IsolateEncryptInitData(0.1, 0.3, data, _appDocDir)));
        _receiveEncrypt.listen((data) {
          _communicateEncrypt(data);
        });
      }
    });
  }

  // ui thread communication with isolate encrypt process
  void _communicateEncrypt(IsolateMessage<String, List<dynamic>> message) async {
    if (message.error) {
      // TODO handle error (ui)
      _encryptError = true;
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
            IsolateInitMessage<IsolateUploadInitData>(
                _receiveUpload.sendPort,
                IsolateUploadInitData(
                    0.3,
                    0.9,
                    _appDocDir.path + "/" + Consts.encryptTargetFile,
                    _receiveStorage.sendPort,
                    cloudProvider)));
        _uploadStarted = true;
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
      // TODO handle error (ui)
      _uploadError = true;
    }

    if (!_uploadError) {
      _updateProgress(message.progress);

      if (message.finished) {
        _fileUrl = message.data[0];
        _isolateUpload.kill();

        _isolateEncMetadata = await Isolate.spawn(
            encMetadata,
          IsolateInitMessage<IsolateEncMetadataInitData>(
              _receiveEncMetadata.sendPort,
            IsolateEncMetadataInitData(
                0.9,
                0.95,
                _appDocDir,
                files,
                _key,
                _fileUrl,
                _fileSize)
          )
        );
        _encMetadataStarted = true;
        _step = Strings.encryptProgressTextMetadata;
        _receiveEncMetadata.listen((data){
          _communicateEncMetadata(data);
        });
      }
    }
  }

  void _communicateEncMetadata(IsolateMessage<String, List<dynamic>> message) async {
    if (message.error){
      // TODO handle error (ui)
      _metadataError = true;
    }

    if (!_metadataError){
      _updateProgress(message.progress);

      if (message.finished){
        var file = message.data[0];
        _isolateEncMetadata.kill();

        _isolateUpload = await Isolate.spawn(
            upload,
            IsolateInitMessage<IsolateUploadInitData>(
                _receiveUploadMetadata.sendPort,
                IsolateUploadInitData(
                    0.95,
                    1.0,
                    file,
                    _receiveStorage.sendPort,
                    cloudProvider)));
        _uploadStarted = true;
        _receiveUploadMetadata.listen((data) {
          _communicateMetadataUpload(data);
        });
      }
    }
  }

  void _communicateMetadataUpload(IsolateMessage<String, List<dynamic>> message) async {
    if (message.error){
      // TODO handle error (ui)
      _uploadError = true;
    }

    if (!_uploadError) {
      _updateProgress(message.progress);

      if (message.finished) {
        var url = message.data[0];
        _isolateUpload.kill();

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

  // zip files before encryption
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

  // isolate encryption
  static void encrypt(IsolateInitMessage<IsolateEncryptInitData> message) async {
    Filecrypt encFile = Filecrypt();

    try {
      // check if libsodium is supported for platform
      if (!Libsodium.supported()) {
        throw FormatException("Libsodium not supported");
      }

      // start encryption
      File sourceFile = File(message.data.file);
      File targetFile =
          File(message.data.appDir.path + "/" + Consts.encryptTargetFile);

      ProgressOject progress = ProgressOject(message.sendPort, message.data.progressStart, message.data.progressEnd);
      encFile.init(sourceFile, CryptoMode.enc);
      bool success =
          encFile.writeIntoFile(targetFile, callback: progress.progress);
      var key = base64.encode(encFile.getKey());
      encFile.clear();
      sourceFile.deleteSync();
      print("finished file encryption");
      var size = targetFile.lengthSync();

      if (!success) {
        message.sendPort.send(IsolateMessage<String, List<dynamic>>(
            0.0, true, true, "Encryption failed", null));
      } else {
        message.sendPort
            .send(IsolateMessage<String, List<dynamic>>(message.data.progressEnd, true, false, null, [key, size]));

        key = "";
      }
    } catch (e) {
      print(e.toString());
      encFile.clear();
      message.sendPort.send(
          IsolateMessage<String, List<dynamic>>(0.0, true, true, "File error", null));
    }
  }

  // isolate upload
  // TODO error handling
  static void upload(IsolateInitMessage<IsolateUploadInitData> message) async {
    File targetFile = File(message.data.file);
    IsolateCommunication comm = IsolateCommunication(message.data.send);
    Storage storage = IsolateStorage(comm);
    IsolateVoidFunctions voidFunctions = IsolateVoidFunctions(comm);
    CloudClient client =
        await CloudClientFactory.create(message.data.cloudProvider, storage);
    if (!(await client.hasCredentials())) {
      await client.authenticate(voidFunctions.openURL);
    }

    ProgressOject progress = ProgressOject(message.sendPort, message.data.progressStart, message.data.progressEnd);
    var fileID = await client.createFile(Filecrypt.randomFilename(), targetFile,
        progress: progress.progress);
    await client.setAccessibility(fileID, true);
    var url = await client.getURL(fileID);
    targetFile.deleteSync();
    message.sendPort
        .send(IsolateMessage<String, List<dynamic>>(message.data.progressEnd, true, false, null, [url]));
  }

  // isolate create encrypted metadata
  static void encMetadata(IsolateInitMessage<IsolateEncMetadataInitData> message) async {
    List<int> _rkey = base64.decode(message.data.key);
    int timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    
    List<String> filenames = [];
    for (String file in message.data.files){
      filenames.add(p.basename(file));
    }

    FileMetadata meta = FileMetadata(
        filenames,
        message.data.size,
        timestamp,
        message.data.fileUrl,
        publicKey: message.data.publicKey);

    Filecrypt fcrypt = Filecrypt(_rkey);
    try {
      // encode to json and write into sourceFile
      File sourceFile = File(message.data.appDir.path + "/" + Consts.encryptMetadataTmpFile);
      List<int> content = utf8.encode(json.encode(meta));
      var rsource = sourceFile.openSync(mode: FileMode.writeOnly);
      rsource.writeFromSync(content);
      rsource.closeSync();

      // encrypt sourceFile
      ProgressOject progress = ProgressOject(message.sendPort, message.data.progressStart, message.data.progressEnd);
      File targetFile = File(message.data.appDir.path + "/" + Consts.encryptMetadataFile);
      fcrypt.init(sourceFile, CryptoMode.enc, Consts.subkeyIDMetadata);
      bool success = fcrypt.writeIntoFile(targetFile, callback: progress.progress);
      fcrypt.clear();
      sourceFile.deleteSync();
      print("finished metadata encryption");
      if (!success) {
        message.sendPort.send(IsolateMessage<String, List<dynamic>>(
            0.0, true, true, "Encryption failed", null));
      } else {
        message.sendPort
            .send(IsolateMessage<String, List<dynamic>>(message.data.progressEnd, true, false, null, [targetFile.path]));
      }

      _rkey = [];
    } catch (e){
      print(e.toString());
      fcrypt.clear();
      message.sendPort.send(
          IsolateMessage<String, List<dynamic>>(0.0, true, true, "File error", null));
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
