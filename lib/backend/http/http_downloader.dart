import 'dart:io';

import '../../data/utils.dart' as utils;
import '../cloud/cloudClient.dart';

class HttpDownloader {
  static Future<HttpClientResponse> getResponse(String url) async {
    HttpClient client = HttpClient();
    var request = await client.getUrl(Uri.parse(url));
    var response = await request.close();

    if (utils.isValidProvider(url, matchProvider: CloudProvider.GoogleDrive)){
      var cookies = response.cookies;
      for (Cookie cookie in cookies) {
        if (cookie.name.startsWith("download_warning")) {
          var split = cookie.name.split("_");
          if (split.length > 3) {
            var id = split[3];
            for (int i = 4; i < split.length; i++) {
              id = id + "_" + split[i];
            }

            var realUrl = "https://drive.google.com/uc?export=download&confirm=${cookie
                .value}&id=$id";

            request = await client.getUrl(Uri.parse(realUrl));
            request.cookies.add(cookie);
            response = await request.close();
            break;
          }
        }
      }
    }

    return response;
  }
}