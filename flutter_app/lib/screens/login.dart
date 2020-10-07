import 'package:flutter/material.dart';
import 'package:flutterapp/database/db.dart';
import 'package:flutterapp/utility/category_route.dart';
import 'package:meta/meta.dart';
import '../utility/category.dart';
import 'package:flutterapp/form/number_selector.dart';
import '../form/mytextformfield.dart';
import '../data_model/login_model.dart';
import '../form/dropdown_item.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutterapp/data_model/text_storage.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';

class Login extends StatefulWidget {
  final Category category;

  const Login({
    @required this.category,
  }) : assert(category != null);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  LoginModel model = LoginModel();

  String _phoneId = 0.toString();
  String _gender = "";
  List<DropdownItem> _ageRanges = [
    DropdownItem('10 - 19', null),
    DropdownItem('20 - 29', null),
    DropdownItem('30 - 39', null),
    DropdownItem('40 - 49', null),
    DropdownItem('50 - 59', null),
    DropdownItem('+60', null)
  ];
  String _ageRange = "20-29";
  String _status = "University Student";
  List<DropdownItem> _statusOptions = [
    DropdownItem('High School Student', Icons.school),
    DropdownItem('University Student', Icons.account_balance),
    DropdownItem('Intern', Icons.bubble_chart),
    DropdownItem('Worker', Icons.work),
    DropdownItem('Other', Icons.add)
  ];
  bool _registered = false;
  FormCompleted _formCheck = new FormCompleted(false, false, false, false, false);

  void _handleRadioValueChange2(String value) {
    setState(() {
      _gender = value;
      _formCheck.gender = true;
    });
  }

  List<DropdownMenuItem<DropdownItem>> _dropdownMenuItemsAges;
  DropdownItem _selectedAge;

  List<DropdownMenuItem<DropdownItem>> _dropdownMenuItemsStatus;
  DropdownItem _selectedStatus;

  void _initDb() async {
    var db = DBProvider.db;
    var users = await db.getAllUser();
    users.length == 0 ? _registered = false : _registered = true;
  }

  @override
  void initState() {
    _dropdownMenuItemsAges = buildDropdownMenuItems(_ageRanges);
    _selectedAge = null;
    _dropdownMenuItemsStatus = buildDropdownMenuItems(_statusOptions);
    _selectedStatus = null;
    _initDb();
//    _getInstances();
    print(_registered);
    super.initState();
  }

  List<DropdownMenuItem<DropdownItem>> buildDropdownMenuItems(List names) {
    List<DropdownMenuItem<DropdownItem>> items = List();
    for (DropdownItem item in names) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    item.icon != null ? Icon(item.icon) : Icon(Icons.fiber_manual_record),
                    Container(width: 20,),
                    Text(item.name),
                  ],
                ),
              )
            ],
          ),
        )
      );
    }
    return items;
  }

  onChangeDropdownItemAge(DropdownItem selected) {
    setState(() {
      _selectedAge = selected;
      _formCheck.age = true;
    });
  }

  onChangeDropdownItemStatus(DropdownItem selected) {
    setState(() {
      _selectedStatus = selected;
      _formCheck.status = true;
    });
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

  var url = 'https://drive.switch.ch/public.php/webdav/';

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

  var periodicTask = "periodicTask";

  File _activityFile;
  File _accdataFile;
  File _gyrodataFile;
  File _noisedataFile;

  String _activityFilename;
  String _accdataFilename;
  String _gyrodataFilename;
  String _noisedataFilename;

  _getInstances(String data) async {
    var db = DBProvider.db;

    var typeOfData;

    if (data == "activity"){
      typeOfData = await db.queryActivities();
    } else if (data == "acc"){
      typeOfData = await db.queryAccData();
    } else if (data == "gyro"){
      typeOfData = await db.queryGyroData();
    } else {
      typeOfData = await db.queryNoiseData();
    }
//    var activities = await db.queryActivities();
//
//    var accData = await db.queryAccData();
//
//    var gyroData = await db.queryGyroData();
//
//    var noiseData = await db.queryNoiseData();

    var _dataCsv = mapListToCsv(typeOfData);

//    var _activitiesCsv = mapListToCsv(activities);
//    var _accdataCsv = mapListToCsv(accData);
//    var _gyrodataCsv = mapListToCsv(gyroData);
//    var _noisedataCsv = mapListToCsv(noiseData);

    print("uploading data");

//    var activityFilename = await _getFileName("activity");
//    var accdataFilename = await _getFileName("acc");
//    var gyrodataFilename = await _getFileName("gyro");
//    var noisedataFilename = await _getFileName("noise");

    var filename = await _getFileName(data);

//    setState(() {
//      _activityFilename = activityFilename;
//      _accdataFilename = accdataFilename;
//      _gyrodataFilename = gyrodataFilename;
//      _noisedataFilename = noisedataFilename;
//    });

    if (data == "activity"){
      _activityFilename = filename;
    } else if (data == "acc"){
      _accdataFilename = filename;
    } else if (data == "gyro"){
      _gyrodataFilename = filename;
    } else {
      _noisedataFilename = filename;
    }
//
//
//    TextStorage activityStorage = new TextStorage(filename: _activityFilename);
//    TextStorage accdataStorage = new TextStorage(filename: _accdataFilename);
//    TextStorage gyrodataStorage = new TextStorage(filename: _gyrodataFilename);
//    TextStorage noisedataStorage = new TextStorage(filename: _noisedataFilename);

    TextStorage dataStorage = new TextStorage(filename: filename);

//    var activityFile = await activityStorage.writeFile(_activitiesCsv);
//    var accdataFile = await accdataStorage.writeFile(_accdataCsv);
//    var gyrodataFile = await gyrodataStorage.writeFile(_gyrodataCsv);
//    var noisedataFile = await noisedataStorage.writeFile(_noisedataCsv);

    var dataFile = await dataStorage.writeFile(_dataCsv);

    if (data == "activity"){
      _activityFile = dataFile;
    } else if (data == "acc"){
      _accdataFile = dataFile;
    } else if (data == "gyro"){
      _gyrodataFile = dataFile;
    } else {
      _noisedataFile = dataFile;
    }
  }

  activityData() async {
    String filename;
    List<String> data = [];
    await _getInstances("activity").then((value){
      data.add(_activityFile.path);
      filename = _activityFilename;
      data.add("$url/$filename");
    });
    return data;
  }

  accData() async{
    String filename;
    List<String> data = [];
    await _getInstances("acc").then((value){
      data.add(_accdataFile.path);
      filename = _accdataFilename;
      data.add("$url/$filename");
    });
    return data;
  }

  gyroData() async {
    String filename;
    List<String> data = [];
    await _getInstances("gyro").then((value){
      data.add(_gyrodataFile.path);
      filename = _gyrodataFilename;
      data.add("$url/$filename");
    });
    return data;
  }

  noiseData() async {
    String filename;
    List<String> data = [];
    await _getInstances("noise").then((value){
      data.add(_noisedataFile.path);
      filename = _noisedataFilename;
      data.add("$url/$filename");
    });
    return data;
  }

//  String activityFilename(){
//    String filename;
//    _getInstances().then((value){
//      filename = _activityFilename;
//    });
//    return "$url/$filename";
//  }
//
//  String accDataFilename(){
//    String filename;
//    _getInstances().then((value){
//      filename = _accdataFilename;
//    });
//    return "$url/$filename";
//  }
//
//  String gyroDataFilename(){
//    String filename;
//    _getInstances().then((value){
//      filename = _gyrodataFilename;
//    });
//    return "$url/$filename";
//  }
//
//  String noiseDataFilename(){
//    String filename;
//    _getInstances().then((value){
//      filename = _noisedataFilename;
//    });
//    return "$url/$filename";
//  }

  activity() async {
    List<String> data = await activityData();
    print ("activityPath : ${data[0]}");
    print("activityUrl : ${data[1]}");
    return data;
  }

  acc() async {
    List<String> data = await accData();
    return data;
  }

  gyro() async {
    List<String> data = await gyroData();
    return data;
  }

  noise() async {
    List<String> data = await noiseData();
    return data;
  }


  Future<void> _saveData(LoginModel model) async {
    var db = DBProvider.db;
    db.addUser(model);
    _getDatabase();
    Workmanager.registerPeriodicTask(
        "5",
        periodicTask,
        frequency: Duration(hours: 24),
        inputData: {
          'activityPath' : (await activity())[0],
          'activityUrl' : (await activity())[1],
          'accdataPath' : (await acc())[0],
          'accdataUrl' : (await acc())[1],
          'gyrodataPath' : (await gyro())[0],
          'gyrodataUrl' : (await gyro())[1],
          'noisedataPath': (await noise())[0],
          'noisedataUrl' : (await noise())[1],
        }
    );

  }


  @override
  Widget build(BuildContext context) {

    final firstInput = Container(
      height: 100,
      alignment: Alignment.topCenter,
      width: MediaQuery
          .of(context)
          .size
          .width - 60,
      child: Scaffold(
        body: MyTextFormField(
          hintText: 'Should be of the form "w001", "w010", "w100"',
          validator: (String value) {
            final alphanumeric = RegExp(r'^w[0-9]{3}$');
            bool correct = alphanumeric.hasMatch(value);
            print(correct);
            if (value.isEmpty || !correct) {
              return 'Enter a valid username for your profile';
            }
            return null;
          },
          onSaved: (String value) {
            final alphanumeric = RegExp(r'^w[0-9]{3}$');
            bool correct = alphanumeric.hasMatch(value);
            print(correct);
            if (value.isEmpty || !correct) {
              return 'Enter a valid username for your profile';
            } else {
              model.username = value;
              _formCheck.username = true;
              return null;
            }
          },
        ),
      ),
    );

    final username = Container(
//      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: 30,
                ),
                Text(
                  "Username",
                  style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF)),
                  textAlign: TextAlign.left,
                ),
//                firstInput,
              ]
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  width: 30,
                ),
                firstInput,
              ]
          ),
        ],
      ),
    );

    final gender = Container(
        height: 100,
        child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: 30,
              ),
              Container(
                width:MediaQuery
                    .of(context)
                    .size
                    .width - 60,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "Gender",
                        style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF),),
                        textAlign: TextAlign.left,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            NumberSelector(value1: "F", groupValue: _gender, f: _handleRadioValueChange2),
                            NumberSelector(value1: "M", groupValue: _gender, f: _handleRadioValueChange2),
                            NumberSelector(value1: "Other", groupValue: _gender, f: _handleRadioValueChange2)
                          ]
                      )
                    ]
                ),
              )
            ],
          ),
        ));

    final ageRange = Container(
      height: 110,
      child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: 30,
              ),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width - 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Age Range",
                      style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF),),
                      textAlign: TextAlign.left,
                    ),
                    Container(height: 10,),
                    Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width - 60,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.black45),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        )
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<DropdownItem>(
                            hint: Text("Please select one option"),
                            value: _selectedAge,
                            items: _dropdownMenuItemsAges,
                            onChanged: onChangeDropdownItemAge,
                          ),
                        ),
                      )

                    )
                  ],
                ),
              )
            ],
          )
      ),
    );

    final status = Container(
      height: 110,
      child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Status",
                    style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF),),
                    textAlign: TextAlign.left,
                  ),
                  Container(height: 10,),
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width - 60,
                    decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.black45),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        )
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            hint: Text("Please select one option"),
                            value: _selectedStatus,
                            items: _dropdownMenuItemsStatus,
                            onChanged: onChangeDropdownItemStatus,
                          )
                      ),
                    )
                  )
                ],
              )
            ],
          )
      ),
    );

    final deviceInput = Container(
      height: 100,
      alignment: Alignment.topCenter,
      width: MediaQuery
          .of(context)
          .size
          .width - 60,
      child: Scaffold(
        body: MyTextFormField(
          hintText: 'Please enter the name of your eSense earbuds. Ex: "eSense-0283',
          validator: (String value) {
            if (value.isEmpty) {
              return 'Enter a valid name';
            }
            return null;
          },
          onSaved: (String value) {
            if (value.isEmpty ) {
              return 'Enter a valid name';
            } else {
              model.earbudsName = value;
              _formCheck.earbudsName = true;
              return null;
            }
          },
        ),
      ),
    );

    final earbudsName = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: 30,
                ),
                Text(
                  "eSense earbuds name",
                  style: TextStyle(fontSize: 18, color: Color(0xFFF94CBF)),
                  textAlign: TextAlign.left,
                ),
//                firstInput,
              ]
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  width: 30,
                ),
                deviceInput,
              ]
          ),
        ],
      ),
    );

    Future<void> _neverSatisfied() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Successfull'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Your profile has been created correctly'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  _registered = true;
//                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryRoute()),
                  );
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> _missingParts() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Some parts are missing!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please fill the informations requested above'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  _registered = true;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


    final _button = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 150,
          child: RaisedButton(
            onPressed: () {
              Platform.isIOS? model.phoneId = "IOS" : model.phoneId = "Android";
              model.gender = _gender;
              model.ageRange = _selectedAge.name;
              model.status = _selectedStatus.name;
              model.userId = 1;
              if (_formKey.currentState.validate()) {
                if (_phoneId != null && _gender != null &&
                    _ageRange != null && _status != null) {
                  _formKey.currentState.save();
                  _registered = true;
                  _saveData(model);
                  _neverSatisfied();
                } else {
                  _missingParts();
                }
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ),
            child: new Text("Submit", style: TextStyle(fontSize: 17, color: Colors.white),),
//                      borderSide: BorderSide(color: Colors.white),
            color: Color(0xFFF94CBF),
//                    shape: ,
          ),
        )
      ],
    );


    return Scaffold(
        body: ListView(
            children: <Widget>[
              Center(
                  child: Column(
                    children: <Widget>[
                      new Container(
                        height: 10,
                      ),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              username,
                              ageRange,
                              new Divider(height: 7.0, color: Colors.white),
                              status,
                              new Divider(height: 7.0, color: Colors.white),
                              earbudsName,
                              gender,
                              new Divider(height: 30.0, color: Colors.white),
                              _button
                            ],
                          )
                      )
                    ],
                  )
              )
            ]
        )
    );
  }
}

class FormCompleted{
  bool username;
  bool age;
  bool status;
  bool gender;
  bool earbudsName;

  FormCompleted(this.username, this.age, this.status, this.gender, this.earbudsName);
}