
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'dart:convert';


class UploadAlarmReceiver {

  Future _doneFuture;
  final String activityFile;
  final String activityUrl;

  UploadAlarmReceiver({
    this.activityFile,
    this.activityUrl,
  }) {
    _doneFuture = _uploadFile(activityFile, activityUrl);
  }

 _uploadFile(filename, url) async {
    print("Hello");
    final username = 'SqDlnbOL3DjuNSG';
    final password = 'mcss2020*';
    final credentials = '$username:$password';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded", // or whatever
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };
    print("Request");
    var request = MultipartRequest('PUT', Uri.parse(url));
    request.headers.addAll(headers);
    request.files.add(await MultipartFile.fromPath('csv file', filename));
    var res = await request.send();
    return res;
  }

  Future get initializationDone => _doneFuture;

}