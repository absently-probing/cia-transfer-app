import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:isolate';
import 'dart:convert';

import '../../../data/path.dart';
import '../../../data/utils.dart' as utils;
import '../../../data/strings.dart';
import '../../../data/constants.dart';
import '../../../data/metadata.dart';
import '../../../data/isolate_messages.dart';
import '../../../backend/crypto/cryptapi/cryptapi.dart';
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

  String _tmpEncFile;

  bool _downloadError = false;
  bool _decryptError = false;

  bool _metadataExists = false;
  FileMetadata _metadata;

  _DecryptMetadataState(this._url, this._password) {
    _startMetadataDownloadAndDecryption();
  }

  void dispose() {
    _downloadReceive.close();
    _decryptReceive.close();
    super.dispose();
  }

  void _startMetadataDownloadAndDecryption() async {
    _tmpEncFile = Path.getTmpDir() + '/' + Consts.decryptEncMetadata;
    _downloadIsolate = await Isolate.spawn(
        downloadMetadata,
        IsolateInitMessage<IsolateDownloadData>(_downloadReceive.sendPort,
            data: IsolateDownloadData(_url, _tmpEncFile)));
    _downloadReceive.listen((data) {
      _communicateDownload(data);
    });
  }

  void _communicateDownload(
      IsolateMessage<String, List<dynamic>> message) async {
    if (message.error) {
      _downloadError = true;
      _downloadIsolate.kill();
      _showErrorDialog(message.errorData);
    }

    if (!_downloadError) {
      if (message.finished) {
        _downloadIsolate.kill();

        _decryptIsolate = await Isolate.spawn(
            decryptMetadata,
            IsolateInitMessage<IsolateDecryptData>(_decryptReceive.sendPort,
                data: IsolateDecryptData(_tmpEncFile, _password)));
        _decryptReceive.listen((data) {
          _communicateDecrypt(data);
        });
      }
    }
  }

  void _communicateDecrypt(IsolateMessage<String, List<dynamic>> message) {
    if (message.error) {
      _decryptError = true;
      _decryptIsolate.kill();
      _showErrorDialog(message.errorData);
    }

    if (!_decryptError) {
      if (message.finished) {
        _decryptIsolate.kill();

        try {
          var encodedMetadata = utf8.decode(message.data[0]);

          Map metadataMap = json.decode(encodedMetadata);
          _metadata = FileMetadata.fromJson(metadataMap);
          if (_metadata.fileLink == null || !utils.isValidUrl(_metadata.fileLink) ||
              _metadata.timestamp == null ||
              _metadata.publicKey == null ||
              _metadata.size == null || _metadata.size <= 0 ||
              _metadata.filenames == null || _metadata.filenames.length == 0) {
            _showErrorDialog("Invalid metadata");
          } else {
            _showMetadata();
          }
        } catch (e){
          _showErrorDialog("Invalid metadata");
        }
      }
    }
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
                    context, ModalRoute.withName("/decryptHome"));
              },
            )
          ],
        );
      },
    );
  }

  void _showMetadata() {
    setState(() {
      _metadataExists = true;
    });
  }

  ListView _createFileInfo() {
    List table = _metadata.showMetadata();
    List<String> keys = table[0];
    List<String> rkeys = [];
    List<String> values = [];
    Map<String, String> map = table[1];

    for (String key in keys) {
      if (map[key] != "") {
        rkeys.add(key);
        values.add(map[key]);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10.0),
      itemCount: rkeys.length,
      itemBuilder: (BuildContext ctxt, int index) {
        final item = rkeys[index];
        final itemValue = values[index];

        return Card(
            key: Key(item),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Text(
                      item,
                      style: Theme.of(context).primaryTextTheme.body1,
                    )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        itemValue,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).primaryTextTheme.body1,
                      ),
                    ),
                  ),
                ),
              ],
            ));
      },
    );
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
                size: _metadata.size,
                expectedFiles: _metadata.filenames)));
  }

  static void downloadMetadata(
      IsolateInitMessage<IsolateDownloadData> message) async {
    String url = message.data.url;

    var file = File(message.data.destination);
    var error = false;

    try {
      HttpClient client = HttpClient();
      var request = await client.getUrl(Uri.parse(url));
      var response = await request.close();

      if (!file.existsSync()){
        file.createSync(recursive: true);
      }

      var output = file.openSync(mode: FileMode.write);
      var totalbytes = 0;
      response.listen((List event) {
        totalbytes = totalbytes + event.length;

        // 1MB check
        if (totalbytes > 1000 * 1000) {
          throw FormatException("File is to large");
        }

        output.writeFromSync(event);
      }, onDone: () {
        output.closeSync();

        if (error) {
          if (file.existsSync()) {
            file.deleteSync();
          }

          message.sendPort.send(IsolateMessage<String, List<dynamic>>(
              0.0, false, true, "Download failed", null));
        }
        else {
          message.sendPort.send(IsolateMessage<String, List<dynamic>>(
              0.0, true, false, null, null));
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

  static void decryptMetadata(IsolateInitMessage<IsolateDecryptData> message) {
    File sourceFile = File(message.data.file);
    Filecrypt fcrypt;

    try {
      fcrypt = Filecrypt(base64.decode(message.data.password));
      fcrypt.init(sourceFile, CryptoMode.dec, Consts.subkeyIDMetadata);
      List<int> content = fcrypt.writeAllIntoBuffer();
      sourceFile.deleteSync();
      if (content != null && content.length > 0) {
        fcrypt.clear();
        message.sendPort.send(IsolateMessage<String, List<dynamic>>(
            0.0, true, false, null, [content]));
      } else {
        throw Exception("invalid file");
      }
    } catch (e) {
      if (fcrypt != null) {
        fcrypt.clear();
      }

      if (sourceFile.existsSync()){
        sourceFile.deleteSync();
      }

      message.sendPort.send(IsolateMessage<String, List<dynamic>>(
          0.0, false, true, "Decryption failed", null));
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
        body: WillPopScope(
          onWillPop: () async => false,
          child: Column(children: [
            Container(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 40,

                    /*
                  top: (utils.screenHeight(context) -
                          utils.screenSafeAreaPadding(context) -
                          appBar.preferredSize.height) /
                      8,*/

                    bottom: 20),
                child: Text(
                  Strings.decryptMetadata,
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: CircularProgressIndicator(),
            ),
            Spacer(),
          ]),
        ),
      );
    }

    return Scaffold(
        appBar: appBar,
        persistentFooterButtons: [
          Container(
            width: utils.screenWidth(context) - 16,
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
                padding:
                    EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
                child: Text(
                  Strings.decryptMetadataInfo,
                  style: Theme.of(context).textTheme.headline,
                )),
          ),
          //Container(
          Expanded(
            child: _createFileInfo(),
          ) //),
        ]));
  }
}
