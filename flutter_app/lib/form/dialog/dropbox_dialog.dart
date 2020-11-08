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
import 'package:dropbox_client/dropbox_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String dropbox_clientId = 'com.example.strack';
const String dropbox_key = '087es5eaj6t7o09';
const String dropbox_secret = 'qb3fn9rx2w6lrvp';

typedef void MyFormCallback(bool result);

class DropboxDialog extends StatefulWidget {

  final MyFormCallback onSubmit;

  DropboxDialog({this.onSubmit});

  @override
  DropboxDialogState createState() => DropboxDialogState();
}

class DropboxDialogState extends State<DropboxDialog>{
  String accessToken = '4IX4RyB1BjYAAAAAAAAAAdOIA9HKMWAuePxU4iL8IE84H0RF-ovqORLEMyHak4yc';
  bool logged = false;
  bool showInstruction = false;
  String user;

  @override
  void initState() {
    super.initState();
    initDropbox();
  }

  Future initDropbox() async {
    if (dropbox_key == 'dropbox_key') {
      showInstruction = true;
      return;
    }
    await Dropbox.init(dropbox_clientId, dropbox_key, dropbox_secret);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // accessToken = prefs.getString('dropboxAccessToken');
    setState(() {});
  }

  Future authorize() async {
    await Dropbox.authorize().then((value){
      setState(() {
        logged = true;
      });
    });
  }

  Future getAccountName() async {
    // if (await checkAuthorized(true)) {
      final user = await Dropbox.getAccountName();
      print('user = $user');
    // }
  }

  Future upload(String path, String filename) async {
    final result =
    await Dropbox.upload(path, '/$filename', (uploaded, total) {
      print('progress $uploaded / $total');
    });
    print(result);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
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

  var _activitiesCsv;
  var _accdataCsv;
  var _gyrodataCsv;
  var _noisedataCsv;

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

    _activitiesCsv = mapListToCsv(activities);
    _accdataCsv = mapListToCsv(accData);
    _gyrodataCsv = mapListToCsv(gyroData);
    _noisedataCsv = mapListToCsv(noiseData);

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

  }

  uploadFiles() async {
    _getInstances().then((value) async {
      var tempDir = await getTemporaryDirectory();
      var fileNames = [_accdataFilename, _gyrodataFilename, _activityFilename, _noisedataFilename];
      var fileCsvs = [_accdataCsv, _gyrodataCsv, _activitiesCsv, _noisedataCsv];
      for(int i = 0; i < fileNames.length; i++){
        var filepath = '${tempDir.path}/${fileNames[i]}';
        var file = await File(filepath).writeAsString(fileCsvs[i]);
        await upload(filepath, fileNames[i]);
      }
    });
  }

  void submit() async {
    //upload user data
    var db = DBProvider.db;
    var userData = await db.queryUser();
    var _userCsv = mapListToCsv(userData);
    String _userFilename = await _getFileName("user");

    var tempDir = await getTemporaryDirectory();
    var filepath = '${tempDir.path}/$_userFilename';
    var file = await File(filepath).writeAsString(_userCsv);
    await upload(filepath, _userFilename);
    await uploadFiles();
    // db.close();

    widget.onSubmit(true);
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  @override
  Widget build(BuildContext context) {

    final _Loginbutton = Container(
      child: RaisedButton(
        onPressed: () async{
          await authorize();
        },
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(5.0),
        ),
        child: new Text("Login", style: TextStyle(fontSize: 16, color: Colors.white),),
//                      borderSide: BorderSide(color: Colors.white),
        color: Color(0xFF448AFF),
//                    shape: ,
      ),
    );

    final _button = Container(
        child: RaisedButton(
          onPressed: () {
            submit();
          },
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5.0),
          ),
          child: new Text("Upload to Dropbox", style: TextStyle(fontSize: 16, color: Colors.white),),
          color: Color(0xFF448AFF),
          ),
        );


    return SimpleDialog(
      title: Text("Upload to Dropbox cloud:"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: EdgeInsets.fromLTRB(5, 30, 0, 20),
      children: <Widget>[
        Container(
          height: 300,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 30),
                logged ?
                Center(
                    child:
                    new Container(
                      alignment: Alignment(0.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("You are logged!",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                          SizedBox(height: 30,),
                          new Container(
                            width: 100,
                            height: 100,
                            child: Image.asset('assets/images/upload.png'),
                          ),
                          _button
                        ],
                      ),
                    )
                ):
                new
                Center(
                  child:
                  Container(
                    width: 220,
                      alignment: Alignment(0.0, 0.0),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Please log to your Dropbox account before uploading any data:",
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center),
                          Image.asset('assets/images/dropboxLogo.png'),
                          _Loginbutton
                        ],
                      )),
                )
              ]
          ),
        )
      ],
    );
  }
}