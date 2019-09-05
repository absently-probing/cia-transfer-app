import 'strings.dart';

class Consts {
  static const encryptZipFile = Strings.appTitle + " archive.zip";
  static const encryptTargetFile = Strings.appTitle + " efile";
  static const encryptMetadataTmpFile = Strings.appTitle + " mfile";
  static const encryptMetadataFile = Strings.appTitle + " emfile";

  static const decryptEncMetadata = Strings.appTitle + " metafile";
  static const decryptEncFile = Strings.appTitle + " file";
  static const decryptZipFile = Strings.appTitle + " dfile.zip";

  static const keySize = 44;

  static const subkeyIDFile = 0;
  static const subkeyIDMetadata = 1;
}