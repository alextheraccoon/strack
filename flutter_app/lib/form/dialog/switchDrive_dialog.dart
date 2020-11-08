import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/data_model/text_storage.dart';
import 'package:http/http.dart';
import 'package:flutterapp/database/db.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';

typedef void MyFormCallback(bool result);

class SwitchDriveDialog extends StatefulWidget {

  final MyFormCallback onSubmit;

  SwitchDriveDialog({this.onSubmit});

  @override
  SwitchDialogState createState() => SwitchDialogState();
}

class SwitchDialogState extends State<SwitchDriveDialog>{
  final usernameController = TextEditingController();
  final tokenController = TextEditingController();
  final linkController = TextEditingController();
  var _username;
  var _link;
  var _token;
  var valUsername = true;
  var valToken = true;
  var valLink = true;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    tokenController.dispose();
    linkController.dispose();
    super.dispose();
  }

  void submit() async {
    setState(() {
      _username = usernameController.text;
      _link = linkController.text;
      _token = tokenController.text;
    });
    //upload user data
    var db = DBProvider.db;
    var userData = await db.queryUser();
    var _userCsv = mapListToCsv(userData);
    String _userFilename = await _getFileName("user");
    TextStorage userStorage = new TextStorage(filename: _userFilename);
    File userFile = await userStorage.writeFile(_userCsv);
    uploadFile(userFile.path, "$_link/$_userFilename");
    //upload other data files
    _upload();
    widget.onSubmit(false);
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  Future<String> uploadFile(filename, url) async {
    final username = _username;
    final password = _token;
    final credentials = '$username:$password';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded", // or whatever
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };
    var request = MultipartRequest('PUT', Uri.parse(url));
    request.headers.addAll(headers);
    request.files.add(await MultipartFile.fromPath('csv file', filename));
    var res = await request.send();
    print(res.reasonPhrase);
    return res.reasonPhrase;
  }

  _getFileName(String dataType) async {
    var db = DBProvider.db;
    var user = await db.getUser(1);
    var formatter = new DateFormat('yyyy-MM-dd');
    var date;
    var current;
    var hour;
    var minute;
    setState(() {
      date = formatter.format(new DateTime.now());
      current = TimeOfDay.now();
      hour = current.hour.toString();
      minute = current.minute.toString();
    });
    String filename = "${user.username}_${date}_${dataType}_eSense_$hour:$minute.csv";
    print(filename);
    return filename;
  }

  String mapListToCsv(List<Map<String, dynamic>> mapList,
      {ListToCsvConverter converter}) {
    if (mapList == null) {
      return null;
    }
    converter ??= const ListToCsvConverter();
    var data = <List>[];
    var keys = <String>[];
    var keyIndexMap = <String, int>{};
    // Add the key and fix previous records
    int _addKey(String key) {
      var index = keys.length;
      keyIndexMap[key] = index;
      keys.add(key);
      for (var dataRow in data) {
        dataRow.add(null);
      }
      return index;
    }
    for (var map in mapList) {
      // This list might grow if a new key is found
      var dataRow = List(keyIndexMap.length);
      // Fix missing key
      map.forEach((key, value) {
        var keyIndex = keyIndexMap[key];
        if (keyIndex == null) {
          // New key is found
          // Add it and fix previous data
          keyIndex = _addKey(key);
          // grow our list
          dataRow = List.from(dataRow, growable: true)..add(value);
        } else {
          dataRow[keyIndex] = value;
        }
      });
      data.add(dataRow);
    }
    return converter.convert(<List>[]
      ..add(keys)
      ..addAll(data));
  }

  File _activityFile;
  File _accdataFile;
  File _gyrodataFile;
  File _noisedataFile;

  String _activityFilename;
  String _accdataFilename;
  String _gyrodataFilename;
  String _noisedataFilename;

  _getInstances() async {
    var db = DBProvider.db;

    var activities = await db.queryActivities();
    var accData = await db.queryAccData();
    var gyroData = await db.queryGyroData();
    var noiseData = await db.queryNoiseData();

    var _activitiesCsv = mapListToCsv(activities);
    var _accdataCsv = mapListToCsv(accData);
    var _gyrodataCsv = mapListToCsv(gyroData);
    var _noisedataCsv = mapListToCsv(noiseData);

    print("uploading data");

    var activityFilename = await _getFileName("activity");
    var accdataFilename = await _getFileName("acc");
    var gyrodataFilename = await _getFileName("gyro");
    var noisedataFilename = await _getFileName("noise");

    setState(() {
      _activityFilename = activityFilename;
      _accdataFilename = accdataFilename;
      _gyrodataFilename = gyrodataFilename;
      _noisedataFilename = noisedataFilename;
    });

    TextStorage activityStorage = new TextStorage(filename: _activityFilename);
    TextStorage accdataStorage = new TextStorage(filename: _accdataFilename);
    TextStorage gyrodataStorage = new TextStorage(filename: _gyrodataFilename);
    TextStorage noisedataStorage = new TextStorage(filename: _noisedataFilename);

    var activityFile = await activityStorage.writeFile(_activitiesCsv);
    var accdataFile = await accdataStorage.writeFile(_accdataCsv);
    var gyrodataFile = await gyrodataStorage.writeFile(_gyrodataCsv);
    var noisedataFile = await noisedataStorage.writeFile(_noisedataCsv);

    setState(() {
      _activityFile = activityFile;
      _accdataFile = accdataFile;
      _gyrodataFile = gyrodataFile;
      _noisedataFile = noisedataFile;
    });
  }

  _upload() async {
    var res = _getInstances().then((value) async {
      String _accRes = await uploadFile(_accdataFile.path, "$_link/$_accdataFilename");
      String _activityRes = await uploadFile(_activityFile.path, "$_link/$_activityFilename");
      String _gyroRes = await uploadFile(_gyrodataFile.path, "$_link/$_gyrodataFilename");
      String _noiseRes = await uploadFile(_noisedataFile.path, "$_link/$_noisedataFilename");
      print(_accRes);
      print(_activityRes);
      print(_gyroRes);
      print(_noiseRes);
    });
    //TODO: to be checked
    print(res);
  }


  @override
  Widget build(BuildContext context) {

    final _username = Container(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SwitchDrive username:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          SizedBox(height: 10,),
          TextField(
            decoration: InputDecoration(
              labelText: 'Username',
              contentPadding: EdgeInsets.all(8.0),
              fillColor: Colors.white70,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(30.0),
                borderSide: new BorderSide(),
              ),
              filled: true,
              errorText: valUsername ? null : 'Value Can\'t Be Empty',
            ),
            controller: usernameController,
            obscureText: false,
          ),
        ],
      ),
    );

    final _token = Container(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SwitchDrive token:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          SizedBox(height: 10,),
          TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(8.0),
              fillColor: Colors.white70,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(30.0),
                borderSide: new BorderSide(),
              ),
              filled: true,
              labelText: 'Token',
              errorText: valToken ? null : 'Value Can\'t Be Empty',
            ),
            controller: tokenController,
            obscureText: true,
          ),
        ],
      ),
    );

    final _link = Container(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SwitchDrive folder link:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          SizedBox(height: 10,),
          TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(8.0),
              fillColor: Colors.white70,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(30.0),
                borderSide: new BorderSide(),
              ),
              labelText: 'Link',
              errorText: valLink ? null : 'Value Can\'t Be Empty',
            ),
            controller: linkController,
            obscureText: true,
          ),
        ],
      ),
    );

    final _button = Container(
      child: RaisedButton(
        onPressed: () {
          setState(() {
            usernameController.text.isEmpty ? valUsername = false : valUsername = true;
            linkController.text.isEmpty ? valLink = false : valLink = true;
            tokenController.text.isEmpty ? valToken = false : valToken = true;
          });
          if (valToken && valLink && valUsername){
            submit();
          }
          },
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(5.0),
        ),
        child: new Text("Upload to Switch Drive", style: TextStyle(fontSize: 16, color: Colors.white),),
        color: Color(0xFF448AFF),
      )
    );


    return SimpleDialog(
      title: Text("Provide here your credentials:"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: EdgeInsets.fromLTRB(5, 30, 0, 20),
      children: <Widget>[
        Center(
          child: Container(
            height: 500,
            width: 300,
            alignment: Alignment(0.0, 0.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 10),
                  _username,
                  const SizedBox(height: 30),
                  _token,
                  const SizedBox(height: 30),
                  _link,
                  const SizedBox(height: 60),
                  _button,
                ]
            ),
          ),
        )

      ],
    );
  }
}