import 'package:flutter/material.dart';
import 'package:flutterapp/database/DatabaseLoader.dart';
import 'package:flutterapp/database/upload_alarm.dart';
import 'package:flutterapp/screens/profile_page.dart';
import 'package:flutterapp/screens/devices_connected.dart';
import 'package:flutterapp/screens/homepage.dart';
import 'package:flutterapp/screens/login.dart';
import 'package:flutterapp/database/db.dart';
import 'package:flutterapp/screens/overview.dart';
import 'package:workmanager/workmanager.dart';
import '../database/db.dart';
import 'backdrop.dart';
import 'category.dart';
import 'category_title.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutterapp/data_model/text_storage.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class CategoryRoute extends StatefulWidget {

  @override
  _CategoryRouteState createState() => _CategoryRouteState();

}

Future<void> upload(var filename, var url) async {
  var alarm = new UploadAlarmReceiver(activityFile:filename, activityUrl: url );
  var res = await alarm.initializationDone;
  print("done ${res.reasonPhrase}");
}

var url = 'https://drive.switch.ch/public.php/webdav/';

void callbackDispatcher() {
  print('callbackDispatcher');
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case periodicTask:
//                print(inputData['activityPath']);
//                print(inputData['activityUrl']);
//                print(inputData['accdataPath']);
//                print(inputData['accdataUrl']);
//                print(inputData['gyrodataPath']);
//                print(inputData['gyrodataUrl']);
//                print(inputData['noisedataPath']);
//                print(inputData['noisedataUrl']);
//      await upload((await _CategoryRouteState.activity())[0], (await _CategoryRouteState.activity())[1]);
//      await upload((await _CategoryRouteState.acc())[0], (await _CategoryRouteState.acc())[1]);
//      await upload((await _CategoryRouteState.gyro())[0], (await _CategoryRouteState.gyro())[1]);
//      await upload((await _CategoryRouteState.noise())[0], (await _CategoryRouteState.noise())[1]);
      await upload(inputData['activityPath'], inputData['activityUrl']);
      await upload(inputData['accdataPath'], inputData['accdataUrl']);
      await upload(inputData['gyrodataPath'], inputData['gyrodataUrl']);
      await upload(inputData['noisedataPath'], inputData['noisedataUrl']);

      break;
    case Workmanager.iOSBackgroundTask:
      print("iOS background fetch delegate ran");
      break;
}
//Return true when the task executed successfully or not
return Future.value(true);
});

}

const simpleTaskKey = "simpleTask";
const periodicTask = "periodicTask";

class _CategoryRouteState extends State<CategoryRoute> {
  Category _defaultCategory;
  Category _currentCategory;
  Widget _currentWidget;
  final _categories = <Category>[];
  static const _categoryNames = <String>[
    'Home',
    'Activities',
    'Account',
    'Devices Connected',
  ];
  static const _baseColors = <ColorSwatch>[
    ColorSwatch(0xFF448AFF, {
      'highlight': Color(0xFF82B1FF),
      'splash': Color(0xFF448AFF),
    }),
    ColorSwatch(0xFFFFD28E, {
      'highlight': Color(0xFFFFD28E),
      'splash': Color(0xFFFFA41C),
    }),
    ColorSwatch(0xFFFFB7DE, {
      'highlight': Color(0xFFFFB7DE),
      'splash': Color(0xFFF94CBF),
    }),
    ColorSwatch(0xFFCE9A9A, {
      'highlight': Color(0xFFF94D56),
      'splash': Color(0xFF912D2D),
      'error': Color(0xFF912D2D),
    }),
    ColorSwatch(0xFFD7C0E2, {
      'highlight': Color(0xFFD7C0E2),
      'splash': Color(0xFFCA90E5),
    }),
    ColorSwatch(0xFF81A56F, {
      'highlight': Color(0xFF81A56F),
      'splash': Color(0xFF7CC159),
    }),
  ];
  static const _icons = <IconData>[
    Icons.home,
    Icons.book,
    Icons.person,
    Icons.headset_mic
  ];
  bool _registered = false;
  int _userLength = 0;
  bool sampling = false;
  String eSenseName = 'eSense-0283';

//  var periodicTask = "periodicTask";



  static _getFileName(String dataType) async {
    var db = new DatabaseLoader(typeOfData: "user");
    print("E");
    var user = await db.initializationDone;
    var formatter = new DateFormat('yyyy-MM-dd');
    var date;
    var current;
    var hour;
    var minute;
//    setState(() {
      date = formatter.format(new DateTime.now());
      current = TimeOfDay.now();
      hour = current.hour.toString();
      minute = current.minute.toString();
//    });
    String filename = "${user.username}_${date}_${dataType}_eSense_$hour:$minute.csv";
    return filename;
  }


  static String mapListToCsv(List<Map<String, dynamic>> mapList,
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

  static File _activityFile;
  static File _accdataFile;
  static File _gyrodataFile;
  static File _noisedataFile;

  static String _activityFilename;
  static String _accdataFilename;
  static String _gyrodataFilename;
  static String _noisedataFilename;

  static _getInstances(String data) async {
    print("D");
//    var db = DBProvider.db;

    var typeOfData;
//    try {
//      if (data == "activity"){
//        typeOfData = await db.queryActivities();
//      } else if (data == "acc"){
//        typeOfData = await db.queryAccData();
//      } else if (data == "gyro"){
//        typeOfData = await db.queryGyroData();
//      } else {
//        typeOfData = await db.queryNoiseData();
//      }
//    } catch (e){
//      print(e);
//    }

    var db = new DatabaseLoader(typeOfData: data);
    print("E");
    typeOfData = await db.initializationDone;
    print("F");
//    var activities = await db.queryActivities();
//
//    var accData = await db.queryAccData();
//
//    var gyroData = await db.queryGyroData();
//
//    var noiseData = await db.queryNoiseData();

    var _dataCsv = mapListToCsv(typeOfData);
    print("G");

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
    print("H");

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
    print("I");
    TextStorage dataStorage = new TextStorage(filename: filename);

//    var activityFile = await activityStorage.writeFile(_activitiesCsv);
//    var accdataFile = await accdataStorage.writeFile(_accdataCsv);
//    var gyrodataFile = await gyrodataStorage.writeFile(_gyrodataCsv);
//    var noisedataFile = await noisedataStorage.writeFile(_noisedataCsv);
    print("L");
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
    print("M");
  }

  static activityData() async {
    String filename;
    List<String> data = [];
    print("B");
    await _getInstances("activity").then((value){
      print("C");
      data.add(_activityFile.path);
      filename = _activityFilename;
      data.add("$url/$filename");
      print("N");
    });
    return data;
  }

  static accData() async{
    String filename;
    List<String> data = [];
    print("B");
    await _getInstances("acc").then((value){
      print("C");
      data.add(_accdataFile.path);
      filename = _accdataFilename;
      data.add("$url/$filename");
    });
    return data;
  }

  static gyroData() async {
    String filename;
    List<String> data = [];
    await _getInstances("gyro").then((value){
      data.add(_gyrodataFile.path);
      filename = _gyrodataFilename;
      data.add("$url/$filename");
    });
    return data;
  }

  static noiseData() async {
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

  static activity() async {
    print("A");
    List<String> data = await activityData();
    print ("activityPath : ${data[0]}");
    print("activityUrl : ${data[1]}");
    return data;
  }

  static acc() async {
    List<String> data = await accData();
    return data;
  }

  static gyro() async {
    List<String> data = await gyroData();
    return data;
  }

  static noise() async {
    List<String> data = await noiseData();
    return data;
  }


  _initDb() async {
    var db = DBProvider.db;
    var users = await db.getAllUser();
    setState(() {
      _userLength = users.length;
    });
  }

  @override
  void initState(){
    _initDb().then((value){
      _userLength == 0 ? _registered = false : _registered = true;
    });
    print('init work manager');
    WidgetsFlutterBinding.ensureInitialized();
    Workmanager.initialize(callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: true, // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
    super.initState();
    for (var i = 0; i < _categoryNames.length; i++) {
      var category = Category(
        name: _categoryNames[i],
        color: _baseColors[i],
        icon: _icons[i],
      );
      if (i == 0) {
        _defaultCategory = category;
      }
      _categories.add(category);
    }
  }

  /// Function to call when a [Category] is tapped.
  void _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
      if (category.name == "Home"){
        _currentWidget = Homepage(category: _currentCategory,);
      } else if (category.name == "Activities") {
        _currentWidget = Overview(category: _currentCategory,);
      } else if (category.name == "Account"){
        if (_registered == false){
          _currentWidget = Login(category: _currentCategory,);
        } else {
          _currentWidget = ProfilePage(category: _currentCategory,);
        }
      } else {
        _currentWidget = DevicesList(category: _currentCategory,);
      }
    });
  }

  /// Makes the correct number of rows for the list view.
  ///
  /// For portrait, we use a [ListView].
  Widget _buildCategoryWidgets() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return CategoryTile(
          category: _categories[index],
          onTap: _onCategoryTap,
        );
      },
      itemCount: _categories.length,
    );
  }

  @override
  Widget build(BuildContext context) {

    final listView = Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 48.0,
      ),
      child: _buildCategoryWidgets(),
    );

    return Backdrop(
      currentCategory:
      _currentCategory == null ? _defaultCategory : _currentCategory,
      frontPanel: _currentCategory == null
          ? Homepage(category: _defaultCategory,)
          : _currentWidget,
      backPanel: listView,
      frontTitle: Image.asset('assets/images/strack_logo.png', height: 35, alignment: Alignment(1.0, 1.0),),
      backTitle: Text('Menu'),
    );
  }
}