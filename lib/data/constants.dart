import 'strings.dart';

class Consts {
  static const encryptDir = "upload";
  static const encryptZipFile = encryptDir + "/archive.zip";
  static const encryptTargetFile = encryptDir + "/encrypted";
  static const encryptMetadataTmpFile = encryptDir + "/metadata";
  static const encryptMetadataFile = encryptDir +"/encryptedMetadata";

  static const decryptDir = "download";
  static const decryptEncMetadata = decryptDir + "/metafile";
  static const decryptEncFile =  decryptDir + "/encrypted";
  static const decryptZipFile = decryptDir + "/archive.zip";
  static const decryptExtractDir = decryptDir + "/extract";

  static const keySize = 44;

  static const subkeyIDFile = 0;
  static const subkeyIDMetadata = 1;
}