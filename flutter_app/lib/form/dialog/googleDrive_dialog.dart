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
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:flutterapp/form/dialog/googleAuthClient.dart';
import 'package:googleapis/drive/v3.dart' as ga;

typedef void MyFormCallback(bool result);

class GoogleDriveDialog extends StatefulWidget {

  final MyFormCallback onSubmit;

  GoogleDriveDialog({this.onSubmit});

  @override
  GoogleDialogState createState() => GoogleDialogState();
}

class GoogleDialogState extends State<GoogleDriveDialog>{

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  void submit() async {
    //upload user data
    var db = DBProvider.db;
    var userData = await db.queryUser();
    var _userCsv = mapListToCsv(userData);
    String _userFilename = await _getFileName("user");
    TextStorage userStorage = new TextStorage(filename: _userFilename);
    File userFile = await userStorage.writeFile(_userCsv);

    final googleSignIn = signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.DriveScope]);
    final signIn.GoogleSignInAccount account = await googleSignIn.signIn();
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    _getInstances().then((value) async {
      var filenames = [_userFilename, _accdataFilename, _gyrodataFilename, _activityFilename, _noisedataFilename];
      var files = [userFile, _accdataFile, _gyrodataFile, _activityFile, _noisedataFile];
      for(int i = 0; i < filenames.length; i++){
        await driveApi.files.create(ga.File()
          ..name = filenames[i],
            uploadMedia: ga.Media(files[i].openRead(), files[i].lengthSync()));
      }
    });
    //TODO: to be checked
    widget.onSubmit(true);
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
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

  @override
  Widget build(BuildContext context) {

    final _button = Container(
      child: RaisedButton(
        onPressed: () {
          submit();
        },
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(5.0),
        ),
        child: new Text("Upload to Google Drive", style: TextStyle(fontSize: 16, color: Colors.white),),
        color: Color(0xFF448AFF),
      ),
    );


    return SimpleDialog(
      title: Text("Upload to Google Drive cloud:"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: EdgeInsets.fromLTRB(5, 30, 0, 20),
      children: <Widget>[
        Center(
            child:
            new Container(
              height: 300,
              alignment: Alignment(0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30,),
                  new Container(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/googleDriveIcon.png'),
                  ),
                  SizedBox(height: 30,),
                  _button
                ],
              ),
            )
        ),
      ],
    );
  }
}