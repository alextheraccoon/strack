import 'package:flutter/material.dart';
import 'package:flutterapp/data_model/login_model.dart';
import 'package:flutterapp/form/gender_form.dart';
import 'package:meta/meta.dart';
import '../utility/category.dart';
import 'package:flutterapp/database/db.dart';
import 'package:flutterapp/utility/category_route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterapp/form/age_form.dart';
import 'package:flutterapp/form/status_form.dart';
import 'package:flutterapp/data_model/text_storage.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';


class ProfilePage extends StatefulWidget {
  final Category category;

  const ProfilePage({
    @required this.category,
  }) : assert(category != null);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  static LoginModel _currentUser;
  bool _logged = false;
  bool _isActive = false;
  final myController = TextEditingController();
  bool _validate = true;
  final eSenseController = TextEditingController();
  bool _validateeSense = true;
  bool _tobeUploaded = false;

  _getUser(int value) async {
    var db = DBProvider.db;
    LoginModel user = await db.getUser(value);
    return user;
  }

  _deleteUser() async {
    var db = DBProvider.db;
    db.deleteUser();
    await Workmanager.cancelAll();
    print('Cancel all tasks completed');
  }

  @override
  void initState() {
    super.initState();
    _getUser(1).then((value){
      setState(() {
        _currentUser = value;
      });
      _currentUser != null ? _logged = true : _logged = false;
    });
    myController.addListener(_latestUsername);
    eSenseController.addListener(_latesteSense);
  }

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
    eSenseController.dispose();

  }

  _latestUsername() async {
    var db = DBProvider.db;
    final alphanumeric = RegExp(r'^w[0-9]{3}$');
    bool correct = alphanumeric.hasMatch(myController.text);
    if (correct){
      setState(() {
        _validate = true;
      });
      _currentUser.username = myController.text;
      db.updateUser(_currentUser);
      if (_tobeUploaded == false){
        _tobeUploaded = true;
        Future.delayed(const Duration(seconds: 180), () {
          _getDatabase();
        });
      }
    } else {
      setState(() {
        _validate = false;
      });

    }
  }

  _latesteSense() async {
    var db = DBProvider.db;
    setState(() {
      _validateeSense = true;
    });
    _currentUser.earbudsName = eSenseController.text;
    db.updateUser(_currentUser);
    if (_tobeUploaded == false){
      _tobeUploaded = true;
      Future.delayed(const Duration(seconds: 180), () {
        _getDatabase();
      });
    }
  }

  void onSubmitAge(String result) async {
    var db = DBProvider.db;
    setState(() {
      _currentUser.ageRange = result;
    });
    db.updateUser(_currentUser);
    if (_tobeUploaded == false){
      _tobeUploaded = true;
      Future.delayed(const Duration(seconds: 180), () {
        _getDatabase();
      });
    }
  }

  void onSubmitStatus(String result) async {
    var db = DBProvider.db;
    setState(() {
      _currentUser.status = result;
    });
    db.updateUser(_currentUser);
    if (_tobeUploaded == false){
      _tobeUploaded = true;
      Future.delayed(const Duration(seconds: 180), () {
        _getDatabase();
      });
    }
  }

  void onSubmitGender(String result) {
    var db = DBProvider.db;
    setState(() {
      _currentUser.gender = result;
    });
    db.updateUser(_currentUser);
    if (_tobeUploaded == false){
      _tobeUploaded = true;
      Future.delayed(const Duration(seconds: 180), () {
        _getDatabase();
      });
    }
  }

  Future<String> uploadFile(filename, url) async {
    final username = 'SqDlnbOL3DjuNSG';
    final password = 'mcss2020*';
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


  _getDatabase() async {
    var db = DBProvider.db;
    var userData = await db.queryUser();
    var _userCsv = mapListToCsv(userData);
    print("uploading data");
    var url = 'https://drive.switch.ch/public.php/webdav/';
    String _userFilename = await _getFileName("user");
    TextStorage userStorage = new TextStorage(filename: _userFilename);
    File userFile = await userStorage.writeFile(_userCsv);
    uploadFile(userFile.path, "$url/$_userFilename");
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
    _getInstances().then((value) async {
      var url = 'https://drive.switch.ch/public.php/webdav/';
      await uploadFile(_accdataFile.path, "$url/$_accdataFilename");
      await uploadFile(_activityFile.path, "$url/$_activityFilename");
      await uploadFile(_gyrodataFile.path, "$url/$_gyrodataFilename");
      await uploadFile(_noisedataFile.path, "$url/$_noisedataFilename");
    });
  }

  Future<LoginModel> _user = Future<LoginModel>.delayed(
    Duration(seconds: 1),
        () => _currentUser,
  );

  @override
  Widget build(BuildContext context) {

    final fullWidth = MediaQuery.of(context).size.width;

    final profile = new Container(
      height: 170,
      width: fullWidth,
      color: Color(0xFFF94CBF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                elevation: 2.0,
                fillColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Color(0xFFFFB7DE),
                  size: 55.0,
                ),
                padding: EdgeInsets.all(10.0),
                shape: CircleBorder(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text( _currentUser.username, style: TextStyle(fontSize: 17, color: Color(0xFFFFB7DE)),),
              )

            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15),
            child: new VerticalDivider(width: 30, thickness: 1, color: Color(0xFFFFB7DE),),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () {
                  _upload();
                },
                elevation: 2.0,
                fillColor: Colors.white,
                child: Icon(
                  Icons.cloud_upload,
                  color: Color(0xFFFFB7DE),
                  size: 55.0,
                ),
                padding: EdgeInsets.all(10.0),
                shape: CircleBorder(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text("Upload data", style: TextStyle(fontSize: 17, color: Color(0xFFFFB7DE)),),
              )
            ],
          )

        ],
      )
    );

    Future<void> _editUsername() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          bool valid = true;
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Edit Username'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      TextField(
                        controller: myController,
                        decoration: InputDecoration(
//                      border: ,
                          hintText: 'Enter a username of form "u001"',
                          errorText: valid ? null : 'Provide a valid username',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Submit'),
                    onPressed: () {
                      if(_validate){
                        setState(() {
                          valid = true;
                        });
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          valid = false;
                        });
                      }
                    },
                  ),
                ],
              );
            }
            );
        },
      );
    }

    Future<void> _editeSenseName() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          bool valid = true;
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('Edit eSense earbuds name'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        TextField(
                          controller: eSenseController,
                          decoration: InputDecoration(
//                      border: ,
                            hintText: 'Enter the name of your earbuds',
                            errorText: valid ? null : 'Provide a valid name',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Submit'),
                      onPressed: () {
                        if(_validateeSense){
                          setState(() {
                            valid = true;
                          });
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            valid = false;
                          });
                        }
                      },
                    ),
                  ],
                );
              }
          );
        },
      );
    }

    final _usernameInfo = new Container(
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Username", style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF)),
                      textAlign: TextAlign.right),
                  Container(width: 20,),
                  Text(_currentUser.username, style: TextStyle(fontSize: 18, color: Colors.black45),
                    textAlign: TextAlign.left),
                ],
              ),
              FlatButton(
                child: Icon(Icons.edit),
                color: Colors.white30,
                onPressed: () => _editUsername(),
              )
            ],
          ),
        )
    );

    final _ageInfo = new Container(
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Age range", style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF)),
                      textAlign: TextAlign.right),
                  Container(width: 20,),
                  Text(_currentUser.ageRange, style: TextStyle(fontSize: 18, color: Colors.black45),
                      textAlign: TextAlign.left),
                ],
              ),
              FlatButton(
                child: Icon(Icons.edit),
                color: Colors.white30,
                onPressed: () => showDialog<void>(context: context,barrierDismissible: false, // user must tap button!
                      builder: (context) => AgeForm(onSubmit: onSubmitAge),
                ),
              )
            ],
          ),
        )
    );

    final _statusInfo = new Container(
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Status", style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF)),
                      textAlign: TextAlign.right),
                  Container(width: 20,),
                  Text(_currentUser.status, style: TextStyle(fontSize: 18, color: Colors.black45),
                      textAlign: TextAlign.left),
                ],
              ),
              FlatButton(
                child: Icon(Icons.edit),
                color: Colors.white30,
                onPressed: () => showDialog<void>(context: context,barrierDismissible: false, // user must tap button!
                  builder: (context) => StatusForm(onSubmit: onSubmitStatus),
                ),
              )
            ],
          ),
        )
    );

    final _genderInfo = new Container(
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Gender", style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF)),
                      textAlign: TextAlign.right),
                  Container(width: 20,),
                  Text(_currentUser.gender, style: TextStyle(fontSize: 18, color: Colors.black45),
                      textAlign: TextAlign.left),
                ],
              ),
              FlatButton(
                child: Icon(Icons.edit),
                color: Colors.white30,
                onPressed: () => showDialog<void>(context: context,barrierDismissible: false, // user must tap button!
                  builder: (context) => GenderForm(onSubmit: onSubmitGender),
                ),
              )
            ],
          ),
        )
    );

    final _earbudsInfo = new Container(
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("eSense name", style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF)),
                      textAlign: TextAlign.right),
                  Container(width: 20,),
                  Text(_currentUser.earbudsName, style: TextStyle(fontSize: 18, color: Colors.black45),
                      textAlign: TextAlign.left),
                ],
              ),
              FlatButton(
                child: Icon(Icons.edit),
                color: Colors.white30,
                onPressed: () => _editeSenseName(),
              )
            ],
          ),
        )
    );


    Future<void> _neverSatisfied() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('You are deleting your account'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to proceed?'),
                  Text('Every data will be deleted and never be restored.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Delete'),
                onPressed: () {
                  _deleteUser();
                  Fluttertoast.showToast(
                      msg: "Your profile has been deleted successfully!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryRoute()),
                  );
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    final deleteProfile = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          onPressed: () => _neverSatisfied(),
          child: Text(
            "Delete Profile",
            style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF)),
          ),
        ),
      ],
    );



    return FutureBuilder(
      future: _user,
        builder: (BuildContext context, AsyncSnapshot snapshot){
        Widget child;
        if (snapshot.hasData) {
          child =
              Scaffold(
                  body: ListView(
                      children: <Widget>[
                        Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                profile,
                                new Divider(height: 40.0, color: Colors.white),
                                _usernameInfo,
                                new Divider(height: 20.0, color: Colors.white),
                                _ageInfo,
                                new Divider(height: 20.0, color: Colors.white),
                                _statusInfo,
                                new Divider(height: 20.0, color: Colors.white),
                                _genderInfo,
                                new Divider(height: 20.0, color: Colors.white),
                                _earbudsInfo,
                                Container(height: 40,),
                                deleteProfile
                              ],
                            )
                        )
                      ]
                  )
              );
        } else if (snapshot.hasError){
          child = Column(
            children: <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ],
          );
        } else {
          child = Column(
            children: <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting'),
              )
            ],
          );
        }
        return child;
        }
        );
  }
}



