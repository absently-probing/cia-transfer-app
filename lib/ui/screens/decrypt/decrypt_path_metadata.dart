import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_upload/backend/crypto/cryptapi/cryptapi.dart';

import 'dart:io';
import 'dart:isolate';
import 'dart:convert';

import '../../../data/utils.dart' as utils;
import '../../../data/strings.dart';
import '../../../data/constants.dart';
import '../../../data/metadata.dart';
import '../../../data/isolate_messages.dart';
import 'decrypt_path_progress_bar.dart';

class IsolateDownloadData {
  final String url;
  final String destination;

  IsolateDownloadData(this.url, this.destination);
}

class IsolateDecryptData {
  final String file;
  final String password;

  IsolateDecryptData(this.file, this.password);
}

class DecryptMetadata extends StatefulWidget {
  final String _url;
  final String _password;

  DecryptMetadata(this._url, this._password);

  @override
  _DecryptMetadataState createState() =>
      _DecryptMetadataState(this._url, this._password);
}

class _DecryptMetadataState extends State<DecryptMetadata> {
  final String _url;
  final String _password;

  Isolate _downloadIsolate;
  Isolate _decryptIsolate;

  ReceivePort _downloadReceive = ReceivePort();
  ReceivePort _decryptReceive = ReceivePort();

  String _tmpPath;
  String _tmpEncFile;

  bool _decryptingStarted = false;

  bool _metadataExists = false;
  FileMetadata _metadata;

  _DecryptMetadataState(this._url, this._password) {
    _startMetadataDownloadAndDecryption();
  }

  void dispose() {
    _downloadIsolate.kill(priority: Isolate.immediate);

    if (_decryptingStarted) {
      _decryptIsolate.kill(priority: Isolate.immediate);
    }

    _downloadReceive.close();
    _decryptReceive.close();
    super.dispose();
  }

  void _startMetadataDownloadAndDecryption() async {
    _tmpPath = (await getTemporaryDirectory()).path;
    _tmpEncFile = _tmpPath + '/' + Consts.decryptEncMetadata;
    _downloadIsolate = await Isolate.spawn(
        downloadMetadata,
        IsolateInitMessage<IsolateDownloadData>(
            _downloadReceive.sendPort, IsolateDownloadData(_url, _tmpEncFile)));
    _downloadReceive.listen((data) {
      _communicateDownload(data);
    });
  }

  void _communicateDownload(
      IsolateMessage<String, List<dynamic>> message) async {
    if (message.finished) {
      _downloadIsolate.kill();
      // TODO validate metadata file length (should be less than 1MB)
      _decryptIsolate = await Isolate.spawn(
          decryptMetadata,
          IsolateInitMessage<IsolateDecryptData>(_decryptReceive.sendPort,
              IsolateDecryptData(_tmpEncFile, _password)));
      _decryptReceive.listen((data) {
        _communicateDecrypt(data);
      });
      _decryptingStarted = true;
    }
  }

  void _communicateDecrypt(IsolateMessage<String, List<dynamic>> message) {
    if (message.finished) {
      _decryptIsolate.kill();
      var encodedMetadata = utf8.decode(message.data[0]);

      Map metadataMap = json.decode(encodedMetadata);
      _metadata = FileMetadata.fromJson(metadataMap);
      if (_metadata.fileLink == null ||
          _metadata.timestamp == null ||
          _metadata.publicKey == null ||
          _metadata.size == null ||
          _metadata.filenames == null) {
        // TODO handle error (wrong metadata)
      } else {
        _showMetadata();
      }
    }
  }

  void _showMetadata() {
    setState(() {
      _metadataExists = true;
    });
  }

  List<TableRow> _createFileInfo() {
    List<TableRow> showInfo = [];

    List table = _metadata.showMetadata();
    List<String> keys = table[0];
    Map<String, String> map = table[1];

    for (String key in keys) {
      if (map[key] != "") {
        showInfo.add(
          TableRow(children: [
            Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                child: Text(
                  key,
                  style: Theme.of(context).primaryTextTheme.body1,
                )),
            Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              child: Text(
                map[key],
                style: Theme.of(context).primaryTextTheme.body1,
              ),
            ),
          ]),
        );
      }
    }

    return showInfo;
  }

  void _cancelPressed() {
    Navigator.pop(context);
  }

  void _continuePressed() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DecryptProgress(
                url: _metadata.fileLink,
                password: _password,
                size: _metadata.size)));
  }

  static void downloadMetadata(
      IsolateInitMessage<IsolateDownloadData> message) async {
    String url = message.data.url;

    HttpClient client = HttpClient();
    var request = await client.getUrl(Uri.parse(url));
    var response = await request.close();
    var tmpFile = message.data.destination;

    var file = File(tmpFile);
    var output = file.openSync(mode: FileMode.write);
    var totalbytes = 0;
    response.listen((List event) {
      totalbytes = totalbytes + event.length;

      // 1MB check
      if (totalbytes > 1000 * 1000){
        throw FormatException("File is to large");
      }

      output.writeFromSync(event);
    }, onDone: () {
      output.closeSync();
      message.sendPort.send(
          IsolateMessage<String, List<dynamic>>(0.0, true, false, null, null));
    }, onError: (e) {
      output.closeSync();
      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, e.toString(), null));
    });
  }

  static void decryptMetadata(IsolateInitMessage<IsolateDecryptData> message) {
    File sourceFile = File(message.data.file);
    Filecrypt fcrypt = Filecrypt(base64.decode(message.data.password));
    try {
      fcrypt = Filecrypt(base64.decode(message.data.password));
      fcrypt.init(sourceFile, CryptoMode.dec, Consts.subkeyIDMetadata);
      List<int> content = fcrypt.writeAllIntoBuffer();
      fcrypt.clear();
      sourceFile.deleteSync();
      if (content != null && content.length > 0) {
        message.sendPort.send(IsolateMessage<String, List<dynamic>>(
            0.0, true, false, null, [content]));
      } else {
        message.sendPort.send(IsolateMessage<String, List<dynamic>>(
            0.0, false, true, "Empty file", null));
      }
    } catch (e) {
      fcrypt.clear();
      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, e.toString(), null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      centerTitle: true,
      title: Text(Strings.decryptMetadataLabel),
    );

    if (!_metadataExists) {
      return Scaffold(
        appBar: appBar,
        body: Container(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
                left: 30,
                right: 30,
                top: (utils.screenHeight(context) -
                        utils.screenSafeAreaPadding(context) -
                        appBar.preferredSize.height) /
                    8,
                bottom: 20),
            child: Text(
              Strings.decryptMetadata,
              style: Theme.of(context).textTheme.headline,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      persistentFooterButtons: [
        Container(
          width: utils.screenWidth(context) - 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: OutlineButton(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  hoverColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    _cancelPressed();
                  },
                  //icon: Icon(
                  //  Icons.cloud_upload,
                  //),
                  child: Text(
                    Strings.decryptMetadataCancelButton,
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: OutlineButton(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  hoverColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    _continuePressed();
                  },
                  //icon: Icon(
                  //  Icons.cloud_upload,
                  //),
                  child: Text(
                    Strings.decryptMetadataReceiveButton,
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            Padding(
                padding:
                    EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
                child: Text(
                  Strings.decryptMetadataInfo,
                  style: Theme.of(context).textTheme.headline,
                )),
            Container(
                child: Table(
              defaultColumnWidth: IntrinsicColumnWidth(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: _createFileInfo(),
            )),
          ])),
    );
  }
}
