import 'package:path_provider/path_provider.dart';

import 'dart:io' show Platform;

class Path {
  static String _tmpDir = "";
  static String _docDir = "";
  static String _externalDir = "";
  static final String androidStoragePrefix = "/storage/emulated/0/";

  static void initDirs() async {
    if (Platform.isAndroid){
      _tmpDir = (await getTemporaryDirectory()).path;
      _docDir = (await getApplicationDocumentsDirectory()).path;
      _externalDir = (await getExternalStorageDirectory()).path;
      return;
    }

    if (Platform.isIOS){
      _tmpDir = (await getTemporaryDirectory()).path;
      _docDir = (await getApplicationDocumentsDirectory()).path;
      _externalDir = _docDir;
      return;
    }

    throw Exception("Platform not supported");
  }

  static String getTmpDir() {
    return _tmpDir;
  }

  static String getDocDir() {
    return _docDir;
  }

  static String getExternalDir(){
    return _externalDir;
  }
}