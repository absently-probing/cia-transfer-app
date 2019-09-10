import 'strings.dart';

class Consts {
  static const encryptZipFile = "upload/archive.zip";
  static const encryptTargetFile = "upload/encrypted";
  static const encryptMetadataTmpFile = "upload/metadata";
  static const encryptMetadataFile = "upload/encryptedMetadata";

  static const decryptEncMetadata = "download/metafile";
  static const decryptEncFile = "download/encrypted";
  static const decryptZipFile = "download/archive.zip";
  static const decryptExtractDir = "download/extract";

  static const keySize = 44;

  static const subkeyIDFile = 0;
  static const subkeyIDMetadata = 1;
}