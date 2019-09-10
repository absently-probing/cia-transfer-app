import 'dart:core';
import 'dart:io';

import '../cloudClient.dart' as cloudClient;
import '../../storage/storage.dart';

import "dart:async";
import "dart:convert";

import "package:http/http.dart" as http;
import "package:googleapis_auth/auth_io.dart" as auth;
import "package:googleapis/drive/v3.dart" as drive;


class GoogleDriveClient extends cloudClient.CloudClient {
  cloudClient.CloudProvider provider = cloudClient.CloudProvider.GoogleDrive;
  Storage storage;
  static const CREDENTIALS_KEY = "credentials_google-drive";

  var _id = new auth.ClientId("368297135935-n553e3fd9k3smbti9rp7uv95k235gjv8.apps.googleusercontent.com", "r3MI47zrje3SnwSUKW_J8LIm");
  var _scopes = ["https://www.googleapis.com/auth/drive.file"];

  GoogleDriveClient(Storage storage) {
    this.storage = storage;
  }

  Future<void> authenticate(void callback(String url)) async {
    var client = http.Client();
    await auth.obtainAccessCredentialsViaUserConsent(_id, _scopes, client, callback).then((auth.AccessCredentials credentials) {
      print("into it");
      client.close();
      storage.set(CREDENTIALS_KEY, _serializeAccessCredentials(credentials));
    });
  }

  Future<String> createFile(String name, File localFile, {progress(int state, int quota, bool done)}) async {
      var client = await _getAuthorizedClient();
      Stream<List<int>> stream = localFile.openRead();
      final int size = localFile.lengthSync();
      var uploaded = 0;
      var stream2 = stream.map((chunk) {
        uploaded += chunk.length;
        progress(uploaded, size, false);
        return chunk;
      });

      var fileID = _writeFile(name, stream2, size, client);
      return fileID;
  }

  Future<void> setAccessibility(String fileID, bool accessible) async {
    var client = await _getAuthorizedClient();
    var api = drive.DriveApi(client);
    var permission = drive.Permission();
    var accessibility = await getAccessibility(fileID);
    if(accessible && !accessibility) {
      permission.type = "anyone";
      permission.role = "reader";
      await api.permissions.create(permission, fileID).whenComplete(() {
        client.close();
      });
    }
    if (!accessible) {
      var permissions = await _getAccessibilityPermissions(fileID);
      for(int i = 0; i < permissions.length; i++) {
        await api.permissions.delete(fileID, permissions[i].id);
      }
      client.close();
    }
  }

  Future<String> _writeFile(String name, Stream<List<int>> content, int contentSize, http.Client client) async {
    var api = drive.DriveApi(client);
    var data = drive.Media(content, contentSize);
    var driveFile = drive.File()..name = name;
    var uploadedFile = await api.files.create(driveFile, uploadMedia: data);
    return uploadedFile.id;
  }

  Future<http.Client> _getAuthorizedClient() async {
    var client = http.Client();
    var credentials = _unserializeAccessCredentials(await storage.get(CREDENTIALS_KEY));
    return auth.autoRefreshingClient(_id, credentials, client);//Future.value(auth.autoRefreshingClient(_id, credentials, client));
  }

  @override
  Future<bool> hasCredentials() async {
    var encoded = await storage.get(CREDENTIALS_KEY);
    if(encoded != null) {
      try {
        var _ = _unserializeAccessCredentials(encoded);
        return true;
      } catch (e) {}
    }
    return false;
  }

  // ***
  // Serialisierungs Code
  // ***

  String _serializeAccessCredentials(auth.AccessCredentials credentials) {
    var accessToken = _serializeAccessToken(credentials.accessToken);
    var attributes = [accessToken, credentials.refreshToken, credentials.scopes];
    return jsonEncode(attributes);
  }

  List<String> _serializeAccessToken(auth.AccessToken token) {
    var attributes = [token.type, token.data, _serializeDateTime(token.expiry)];
    return attributes;
  }

  String _serializeDateTime(DateTime date) {
    var time = date.toUtc();
    return jsonEncode(time.microsecondsSinceEpoch);
  }

  DateTime _unserializeDateTime(String encoded) {
    return DateTime.fromMicrosecondsSinceEpoch(jsonDecode(encoded), isUtc: true);
  }

  auth.AccessToken _unserializeAccessToken(List encoded) {
    var attributes = encoded;
    var type = attributes[0];
    var data = attributes[1];
    var expiry = _unserializeDateTime(attributes[2]);
    return auth.AccessToken(type, data, expiry);
  }

  auth.AccessCredentials _unserializeAccessCredentials(String encoded){
    var attributes = jsonDecode(encoded);
    var accessToken = _unserializeAccessToken(attributes[0]);
    var refreshToken = attributes[1];
    var scope = attributes[2].cast<String>();
    return auth.AccessCredentials(accessToken, refreshToken, scope);
  }

  @override
  void deleteFile(String fileID) {
    // TODO: implement deleteFile
  }

  @override
  Future<bool> getAccessibility(String fileID) async {
    var permissions = await _getAccessibilityPermissions(fileID);

    return permissions.length > 0;
  }
  
  @override
  Future<String> getURL(String fileID) async {
    var client = await _getAuthorizedClient();
    var api = drive.DriveApi(client);
    drive.File file = await api.files.get(fileID, $fields: "webContentLink");
    client.close();

    return file.webContentLink;
  }

  Future<List<drive.Permission>> _getAccessibilityPermissions(String fileID) async {
    var permissions = await _getPermissions(fileID);
    List<drive.Permission> results = [];

    for(int i = 0; i < permissions.permissions.length; i++) {
      var singlePermission = permissions.permissions[i];
      if(singlePermission.type == "anyone" && singlePermission.role == "reader") {
        results.add(singlePermission);
      }
    }
    return results;
  }

  Future<drive.PermissionList> _getPermissions(String fileID) async {
    var client = await _getAuthorizedClient();
    var api = drive.DriveApi(client);
    var permissions = await api.permissions.list(fileID);
    return permissions;
  }

}


