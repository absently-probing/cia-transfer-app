import 'strings.dart';

class Consts {
  static const encryptZipFile = "archive.zip";
  static const encryptTargetFile = "efile";
  static const encryptMetadataTmpFile = "mfile";
  static const encryptMetadataFile = "emfile";

  static const decryptEncMetadata = "metafile";
  static const decryptEncFile = Strings.appTitle + " file";
  static const decryptZipFile = "dfile.zip";
  static const decryptExtractDir = "extract";

  static const keySize = 44;

  static const subkeyIDFile = 0;
  static const subkeyIDMetadata = 1;
}