import 'dart:io';
import 'googleDriveClient.dart';

enum CloudProvider {
  GoogleDrive,
  DropBox,
  OneDrive
}

abstract class Storage {
  Future<String> get(String key);
  void set(String key, String value);
}

abstract class CloudClient {
  CloudProvider provider;

  Storage storage; //flutter_secure_storage

  //callback gets an URL, which has to be opened in the browser by the user.
  //after processing in browser, authenticate continues with storing credentials
  Future<void> authenticate(void callback(String url));

  //returns fileID
  Future<String> createFile(String name, File localFile);

  void deleteFile(String fileID);

  Future<bool> getAccessibility(String fileID);

  void setAccessibility(String fileID, bool accessible);

  Future<bool> hasCredentials();

}

class CloudClientFactory {
  static CloudClient create(CloudProvider provider, Storage storage) {
    switch(provider) {
      /*case CloudProvider.GoogleDrive: new GoogleDriveClient(storage); break;
      case CloudProvider.DropBox : new DropboxClient(storage); break;
      case CloudProvider.OneDrive: new OneDriveClient(storage); break;*/
      default: return GoogleDriveClient(storage);
    }
  }
}
