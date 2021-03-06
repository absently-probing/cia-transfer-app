import 'dart:io';
import '../storage/storage.dart';
import 'google/googleDriveClient.dart';
import 'dropbox/dropboxClient.dart';

// keep alphabetical order
enum CloudProvider {
  DropBox,
  GoogleDrive,
  OneDrive
}

class CloudCredentialsException implements Exception {
  final String cause;

  CloudCredentialsException({this.cause = ""});

  String toString(){
    return cause;
  }
}

String providerToString(CloudProvider provider) {
  switch(provider) {
    case CloudProvider.DropBox: return "Dropbox";
    case CloudProvider.GoogleDrive: return "Google Drive";
    case CloudProvider.OneDrive: return "OneDrive";
  }
}

String providerDomain(CloudProvider provider){
  switch (provider) {
    case CloudProvider.DropBox: return "dropbox.com";
    case CloudProvider.GoogleDrive: return "drive.google.com";
    case CloudProvider.OneDrive: return "onedrive.com";
  }
}

List<String> providerDomains(){
  List<String> result = [];
  for (CloudProvider provider in CloudProvider.values){
    result.add(providerDomain(provider));
  }

  return result;
}

abstract class CloudClient {
  CloudProvider provider;

  Storage storage; //flutter_secure_storage

  //callback gets an URL, which has to be opened in the browser by the user.
  //after processing in browser, authenticate continues with storing credentials
  Future<void> authenticate(void callback(String url));

  //returns fileID
  Future<String> createFile(String name, File localFile, {progress(int state, int quota, bool done)});

  void deleteFile(String fileID);

  Future<bool> getAccessibility(String fileID);

  void setAccessibility(String fileID, bool accessible);

  Future<bool> hasCredentials();

  Future<String> getURL(String fileID);

}

class CloudClientFactory {
  static CloudClient create(CloudProvider provider, Storage storage) {
    switch(provider) {
      case CloudProvider.DropBox : return DropboxClient(storage);
      case CloudProvider.GoogleDrive: return GoogleDriveClient(storage);
      //case CloudProvider.OneDrive: return OneDriveClient(storage);
      default: return GoogleDriveClient(storage);
    }
  }
}
