import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

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

class IsolateEncryptInitData {
  final String file;
  final Directory appDir;

  IsolateEncryptInitData(this.file, this.appDir);
}

class IsolateUploadInitData {
  final String file;
  final SendPort send;
  final CloudProvider cloudProvider;

  IsolateUploadInitData(this.file, this.send, this.cloudProvider);
}

class IsolateZipInitMessage {
  final List<String> files;
  final SendPort sendPort;
  final Directory appDir;

  IsolateZipInitMessage(this.files, this.sendPort, this.appDir);
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
  ReceivePort _receiveZip = ReceivePort();
  ReceivePort _receiveEncrypt = ReceivePort();
  ReceivePort _receiveUpload = ReceivePort();
  ReceivePort _receiveStorage = ReceivePort();
  Storage storage = MobileStorage();
  IsolateCommunicationHandler _handler;

  String _step = Strings.encryptProgressTextZip;

  double _progress = 0.0;
  String _progressString = "0%";
  Directory _appDocDir;
  String _key = null;

  bool _encryptError = false;
  bool _uploadError = false;
  bool _uploadStarted = false;
  bool _encryptStarted = false;

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

    _receiveZip.close();
    _receiveEncrypt.close();
    _receiveUpload.close();
    _receiveStorage.close();

    super.dispose();
  }

  void startEncryptAndUpload() async {
    _handler = IsolateCommunicationHandler(_receiveStorage, _handleRequest);

    _appDocDir = await getApplicationDocumentsDirectory();
    _isolateZip = await Isolate.spawn(
        zip, IsolateZipInitMessage(files, _receiveZip.sendPort, _appDocDir));
    _receiveZip.listen((data) async {
      if (data == "") {
        //handle error;
      }

      _encryptStarted = true;
      // remove zip progress from navigation
      _updateProgress(0.1);
      _step = Strings.encryptProgressTextEncrypt;
      _isolateEncrypt = await Isolate.spawn(
          encrypt,
          IsolateInitMessage<IsolateEncryptInitData>(_receiveEncrypt.sendPort,
              IsolateEncryptInitData(data, _appDocDir)));
      _receiveEncrypt.listen((data) {
        _communicateEncrypt(data);
      });
    });
  }

  void _communicateEncrypt(IsolateMessage<String, String> message) async {
    if (message.error) {
      // handle error
      _encryptError = true;
    }

    if (!_encryptError) {
      _updateProgress(message.progress);

      if (message.finished) {
        _isolateEncrypt.kill();
        _key = message.data;
        _step = Strings.encryptProgressTextUpload;
        _isolateUpload = await Isolate.spawn(
            upload,
            IsolateInitMessage<IsolateUploadInitData>(
                _receiveUpload.sendPort,
                IsolateUploadInitData(
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

  void _communicateUpload(IsolateMessage<String, String> message) {
    if (message.error) {
      _uploadError = true;
    }

    if (!_uploadError) {
      _updateProgress(message.progress);

      if (message.finished) {
        var url = message.data;
        _isolateUpload.kill();

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ShareSelection(url, _key)));
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

  static void encrypt(
      IsolateInitMessage<IsolateEncryptInitData> message) async {
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

      ProgressOject progress = ProgressOject(message.sendPort, 0.1, 0.3);
      encFile.init(sourceFile, CryptoMode.enc);
      bool success =
          encFile.writeIntoFile(targetFile, callback: progress.progress);
      var key = base64.encode(encFile.getKey());
      encFile.clear();
      sourceFile.deleteSync();
      print("finished");

      if (!success) {
        message.sendPort.send(IsolateMessage<String, String>(
            0.0, true, true, "Encryption failed", null));
      } else {
        message.sendPort
            .send(IsolateMessage<String, String>(0.0, true, false, null, key));

        key = "";
      }
    } catch (e) {
      print(e.toString());
      encFile.clear();
      message.sendPort.send(
          IsolateMessage<String, String>(0.0, true, true, "File error", null));
    }
  }

  // TODO implement upload
  static void upload(IsolateInitMessage<IsolateUploadInitData> message) async {
    File targetFile = File(message.data.file);
    IsolateCommunication comm = IsolateCommunication(message.data.send);
    Storage storage = IsolateStorage(comm);
    IsolateVoidFunctions voidFunctions = IsolateVoidFunctions(comm);
    // TODO remove it
    // TODO create ProcessObject for updating CircleProcessbar
    //Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    CloudClient client =
        await CloudClientFactory.create(message.data.cloudProvider, storage);
    if (!(await client.hasCredentials())) {
      await client.authenticate(voidFunctions.openURL);
    }

    ProgressOject progress = ProgressOject(message.sendPort, 0.3, 0.9);
    var fileID = await client.createFile(Filecrypt.randomFilename(), targetFile,
        progress: progress.progress);
    await client.setAccessibility(fileID, true);
    var url = await client.getURL(fileID);
    targetFile.deleteSync();
    message.sendPort
        .send(IsolateMessage<String, String>(0.9, true, false, null, url));
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
