import 'package:secure_upload/backend/cloud/google/cloudClient.dart' as cloudClient;

import 'dart:convert';
import "dart:io"; //not usable in webApps

class SimpleStorage extends cloudClient.Storage {
  
  Map<String, dynamic> dict = {};
  String filename;
  
  SimpleStorage(String filename) {
    this.filename = filename;
    var localFile = File(filename);
    var fileContent = localFile.readAsStringSync();
    if(fileContent != "") {
      dict = jsonDecode(fileContent);

    } else {
      dict = {};
    }
  }
  
  @override
  String get(String key) {
    return utf8.decode(base64.decode(dict[key]));
  }

  @override
  void set(String key, String value) {
    var utf8str = utf8.encode(value);
    dict[key] = base64.encode(utf8str);
    var localFile = File(filename);
    localFile.writeAsStringSync(jsonEncode(dict));
  }
  
}