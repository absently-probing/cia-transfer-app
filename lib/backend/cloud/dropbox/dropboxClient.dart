import 'dart:io';
import 'dart:async';
import 'dart:convert';

import '../cloudClient.dart' as cloudClient;
import '../../storage/storage.dart';
//import 'package:flutter_app/fileInfo.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;


class DropboxClient extends cloudClient.CloudClient {
  cloudClient.CloudProvider provider = cloudClient.CloudProvider.DropBox;
  Storage storage;
  static const CREDENTIALS_KEY = "credentials_dropbox";
  oauth2.Client authorizeClient;
  final _identifier = "2yvkic4i1gltn3q";
  final _secret = "jscbetyo1xrjgo1";

  DropboxClient(Storage storage) {
    this.storage = storage;
  }

//returns a URL, which has to be opened in the browser by the user
  @override
  Future<String> authenticate(void callback(String url)) async {
    final authorizationEndpointBase = "https://www.dropbox.com/oauth2/authorize";
    final tokenEndpointBase = "https://api.dropboxapi.com/oauth2/token";

    // Application folder access
    // final identifier = "dagt0mp0uhb904q";
    // final secret = "h8asd8dhbz8vdn5";
    // Full dropbox access

    final responseType = "token";

    final redirectUrl = Uri.parse("http://127.0.0.1:12345/authorize");
    final authorizationEndpoint = Uri.parse("$authorizationEndpointBase?client_id=$_identifier");
    final tokenEndpoint = Uri.parse("$tokenEndpointBase");

    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      // String credentialStr = sharedPreferences.getString("credentials");
//      await storage.delete(key: "credentials");
      String credentialStr = await storage.get(CREDENTIALS_KEY);
      var credentials = oauth2.Credentials.fromJson(credentialStr);
      authorizeClient = oauth2.Client(credentials, identifier: _identifier, secret: _secret);
      return credentialStr;
    }
    catch(e) {
      var grant = new oauth2.AuthorizationCodeGrant(_identifier, authorizationEndpoint, tokenEndpoint, secret: _secret);
      await callback(grant.getAuthorizationUrl(redirectUrl).toString());

      var server = await HttpServer.bind(InternetAddress("127.0.0.1"), 12345);
      HttpRequest request = await server.first;
      request.response.close();
      authorizeClient = await grant.handleAuthorizationResponse(request.uri.queryParameters);
      // sharedPreferences.setString("credentials", authorizeClient.credentials.toJson());
      await storage.set(CREDENTIALS_KEY, authorizeClient.credentials.toJson());
      return authorizeClient.credentials.toJson();
    }
  }

  @override
  Future<String> createFile(String path, File file, {progress(int state, int quota, bool done)}) async {
    Stream<List<int>> content = file.openRead();
    int contentSize = await file.length();
    return await _createFileHelper(path, content, contentSize, progress: progress);
  }

  Future<String> _createFileHelper(String path, Stream<List<int>> content, int contentSize, {progress(int state, int quota, bool done)}) async {
    final String createUrl = "https://content.dropboxapi.com/2/files/upload";

    final Map<String, dynamic> parameters = {
      "path": path,
      "mode": "add",
      "autorename": false,
      "mute": false,
      "strict_conflict": false
    };
    Map <String, String> header = {
      "Authorization": "Bearer ${authorizeClient.credentials.accessToken}",
      "Dropbox-API-Arg": jsonEncode(parameters),
      "Content-Type" : "application/octet-stream"
    };

    http.StreamedRequest request = new http.StreamedRequest("POST", Uri.parse(createUrl));
    request.headers.addAll(header);
    int transferredSize = 0;
    content.listen(
            (chunk) {
          request.sink.add(chunk);
          transferredSize += chunk.length;
          if(progress != null) progress(transferredSize, contentSize, false);
        },
        onDone: () {
          request.sink.close();
          if(progress != null) progress(transferredSize, contentSize, true);
        }
    );
    http.StreamedResponse response = await request.send();
    String responseBody = await response.stream.bytesToString();
    var responseObject = jsonDecode(responseBody);
    String id = responseObject["id"];
    return id;
  }

  @override
  void deleteFile(String fileID) async {
    final String deleteUrl = "https://api.dropboxapi.com/2/files/delete_v2";
    final Map<String, String> parameters = {
      "path": fileID,
    };
    final Map<String, String> header = {
      "Content-Type": "application/json"
    };
    http.Response response = await authorizeClient.post(deleteUrl, headers: header, body: jsonEncode(parameters));
  }

  @override
  Future<bool> getAccessibility(String fileID) async {
    final String listLinkUrl = "https://api.dropboxapi.com/2/sharing/list_shared_links";
    final parameters = {
      "path": fileID
    };
    final header = {
      "Content-Type": "application/json"
    };
    http.Response response = await authorizeClient.post(listLinkUrl, headers:header, body: jsonEncode(parameters));
    var responseObject = await jsonDecode(response.body);
    // List of all shared links for a file (including links exposing file in parent directories)
    List<dynamic> links = responseObject["links"];
    // Denotes if there are more shared links not included in response
    bool hasMore = responseObject["has_more"];
    bool hasSharedLinks = links.length > 0 || hasMore;
    return hasSharedLinks;
  }

  @override
  void setAccessibility(String fileID, bool accessible) async {
    final Map<String, String> header = {
      "Content-Type": "application/json"
    };

    if(!accessible) {
      final String listLinkUrl = "https://api.dropboxapi.com/2/sharing/list_shared_links";
      final String revokeUrl = "https://api.dropboxapi.com/2/sharing/revoke_shared_link";
      final sharedLinkParameters = {
        "path": fileID,
        "direct_only": true
      };

      http.Response response = await authorizeClient.post(listLinkUrl, headers: header, body: jsonEncode(sharedLinkParameters));
      List<dynamic> links = await jsonDecode(response.body)["links"];
      for(Map<String, dynamic> link in links) {
        String linkUrl = link["url"];
        final revokeParameters = {
          "url": linkUrl
        };
        await authorizeClient.post(revokeUrl, headers: header, body: jsonEncode(revokeParameters));
      }
    }
    else {
      final String publishUrl = "https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings";
      final parameters = {
        "path": fileID,
        "settings": {
          "requested_visibility": "public",
          "audience": "public",
          "access": "viewer"
        }
      };
      http.Response response = await authorizeClient.post(publishUrl, headers: header, body: jsonEncode(parameters));
    }
  }

  @override
  Future<bool> hasCredentials() async {
    var encoded = await storage.get(CREDENTIALS_KEY);
    if(encoded != null) {
      try {
        var credentials = oauth2.Credentials.fromJson(encoded);
        var _ = oauth2.Client(credentials, identifier: _identifier, secret: _secret);
        return true;
      } catch (e) {}
    }
    return false;
  }

  @override
  Future<String> getURL(String fileID) async {
    return null;
  }

  /*Stream<List<FileInfo>> getNextChildren(String fileID, {int limit}) async* {
    final String listUrl = "https://api.dropboxapi.com/2/files/list_folder";
    final String continueListUrl = "https://api.dropboxapi.com/2/files/list_folder/continue";

    Map<String, dynamic> startParameters = {
      "path": fileID,
      "recursive": false,
      "include_deleted": false,
      "include_mounted_folders": true,
      // "shared_link":
    };
    if(limit != null) {
      startParameters["limit"] = limit;
    }

    final Map<String, String> header = {
      "Content-Type": "application/json"
    };

    String url = listUrl;
    Map<String, dynamic> parameters = startParameters;
    while(true) {
      http.Response response = await authorizeClient.post(url, headers: header, body: jsonEncode(parameters));
      var responseObject =  jsonDecode(response.body);

      List<dynamic> entries = responseObject["entries"];
      String cursor = responseObject["cursor"];
      bool hasMore = responseObject["has_more"];
      List<FileInfo> listFileInfo = entries.map((entry) {
        Map<String, dynamic> record = entry;
        return _extractFileInfo(record);
      }).toList();
      yield listFileInfo;

      url = continueListUrl;
      parameters = {"cursor": cursor};
      if(!hasMore) {
        break;
      }
    }

  }

  FileInfo _extractFileInfo(Map<String, dynamic> entry) {
    FileInfo fileInfo = new FileInfo(entry["id"], entry["name"], entry[".tag"], entry["size"]);
    return fileInfo;
  }*/

}
