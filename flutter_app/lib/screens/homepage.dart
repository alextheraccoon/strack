import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/activity/activity_questionnaire.dart';
import 'package:flutterapp/data_model/device_model.dart';
import 'package:flutterapp/data_model/noise_model.dart';
import 'package:meta/meta.dart';
import '../utility/category.dart';
import '../utility/timer.dart';
import 'package:flutterapp/data_model/gyroscope_model.dart';
import 'package:flutterapp/data_model/accelerometer_model.dart';
import 'package:esense_flutter/esense.dart';
import 'dart:async';
import 'package:flutterapp/data_model/model.dart';
import 'package:flutterapp/database/db.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noise_meter/noise_meter.dart';

class Homepage extends StatefulWidget {
  final Category category;

  const Homepage({
    @required this.category,
  }) : assert(category != null);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  String _deviceName = 'Unknown';
  double _voltage = -1;
  String _deviceStatus = '';
  bool sampling = false;
  String _event = '';
  String _button = 'not pressed';
  List<AccModel> _accData = [];
  List<GyroModel> _gyroData = [];
  List<NoiseModel> _noiseData = [];
  Model _activity = new Model(
    date: DateTime.now().toString(),
    duration: "",
    activity: "",
    engagement: "",
    absorption: "",
    activityId: 0,
  );

  //noise detector
  bool _isRecording = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter = new NoiseMeter();


//  // the name of the eSense device to connect to -- change this to your own device.
  String eSenseName;
  int _activityId;
//
  @override
  void initState() {
    if (this.mounted){
      super.initState();
    }
  }

  void _onDataNoise(NoiseReading noiseReading){
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
    });
    NoiseModel noise = new NoiseModel(maxDecibel: noiseReading.maxDecibel, meanDecibel: noiseReading.meanDecibel, activityId: _activityId);
    _noiseData.add(noise);
    print(noiseReading.toString());
  }

  void _startNoise() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(_onDataNoise);
    } catch (err) {
      print(err);
    }
  }

  void _stopNoise() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  Future<void> _connectToESense() async {
    var db = DBProvider.db;
    await db.getUser(1).then((value) {
      eSenseName = value.earbudsName;
    });

    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');
      if (event.type == ConnectionType.connected) _listenToESenseEvents();
      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) {
        _deviceStatus = "connected";
        Fluttertoast.showToast(
            msg: "Device connected",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    });

    con = await ESenseManager.connect(eSenseName);
    setState(() {
      _deviceStatus = con ? 'connecting' : 'connection failed';
    });
  }

  void _disconnectESense() async {
    await ESenseManager.disconnect();
    setState(() {
      _deviceStatus = "disconnected";
    });
  }

  _registerDevice() async {
    Timer(Duration(seconds: 2), () async => await ESenseManager.getDeviceName());
    print(_deviceName);
    var db = DBProvider.db;
    var formatter = new DateFormat('yyyy-MM-dd');
    DeviceModel device = new DeviceModel(name: eSenseName, firstPairing:formatter.format(new DateTime.now()));
    db.addDevice(device);
    var devices = await db.deviceData();
    print("Devices: $devices");
  }

  void _listenToESenseEvents() async {
    if (_deviceStatus == "connected") {
      ESenseManager.eSenseEvents.listen((event) {
        print('ESENSE event: $event');
          setState(() {
            switch (event.runtimeType) {
              case DeviceNameRead:
                _deviceName = (event as DeviceNameRead).deviceName;
                print(_deviceName);
                break;
              case BatteryRead:
                _voltage = (event as BatteryRead).voltage;
                break;
              case ButtonEventChanged:
                _button = (event as ButtonEventChanged).pressed
                    ? 'pressed'
                    : 'not pressed';
                break;
            }
          });
      });
    }
    _registerDevice();
  }

  StreamSubscription subscription;
  void _startListenToSensorEvents() async {

    // subscribe to sensor event from the eSense device
    ESenseManager.setSamplingRate(32);
    subscription = ESenseManager.sensorEvents.listen((event) {
      print('SENSOR event: $event');
      int _accX = event.accel[0];
      int _accY = event.accel[1];
      int _accZ = event.accel[2];
      int _gyroX = event.gyro[0];
      int _gyroY = event.gyro[1];
      int _gyroZ = event.gyro[2];
      String _timestamp = event.timestamp.toString();
      int _packetIndex = event.packetIndex;
      AccModel elem = new AccModel(x: _accX, y: _accY, z: _accZ, timestamp: _timestamp, packetId: _packetIndex, activityId: _activityId);
      GyroModel gyroElem = new GyroModel(x: _gyroX, y: _gyroY, z: _gyroZ, timestamp: _timestamp, packetId: _packetIndex, activityId: _activityId);
      _accData.add(elem);
      _gyroData.add(gyroElem);
      setState(() {
        _event = event.toString();
      });
    });
    setState(() {
      sampling = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    if (subscription != null){
      subscription.cancel();
    }
    setState(() {
      sampling = false;
    });
  }

  void dispose() {
    super.dispose();
    _disconnectESense();
  }

  void onSubmit(bool result) async {
    print(result);
    if (result){
      Fluttertoast.showToast(
          msg: "Thank you for your answers! Device is now disconnected.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
      );
//      _disconnectESense();
    }
  }

  insertData() async {
    print("acc length: ${_accData.length}");
    print("gyro length: ${_gyroData.length}");
    print("noise length: ${_noiseData.length}");
    var db = DBProvider.db;
    for(var i = 0; i < _accData.length; i++){
      await db.addAccData(_accData[i]);
      await db.addGyroData(_gyroData[i]);
    }
    for (var i = 0; i < _noiseData.length; i++){
      await db.addNoiseData(_noiseData[i]);
    }
    _accData = [];
    _gyroData = [];
    _noiseData = [];
  }


  getInfo(TimerService t) async {
    _activity.activityId = _activityId;
    var formatter = new DateFormat('yyyy-MM-dd');
    _activity.date = formatter.format(new DateTime.now());
    _activity.duration = t.currentDuration.toString().split('.')[0];
  }

  void _handleActivity(TimerService t) async{
    var db = DBProvider.db;
    var user = await db.users();
    if (user.length == 0){
      return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text('You are not logged in!'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Please sing up before starting the activity.'),
                      Container(height: 15,),
                      Text('Go to account page to start!')
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }
                  ),

                ]
            );
          }
          );
    }
    if (_deviceStatus != "connected"){
      return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Device not found!'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Connect a device before starting the activity'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }
                  )
                ]
            );
          }
       );
    } else {
      if (!t.isRunning) {
        await db.activities().then((value){
          var activityId = value.length + 1;
          _activityId = activityId;
          print(_activityId);
        });
        t.start();
        if (!ESenseManager.connected){
          null;
        } else {
          if (!sampling){
            _startListenToSensorEvents();
            _startNoise();
          }
        }
      } else {
        t.stop();
        if (!ESenseManager.connected){
          null;
        } else {
          if (sampling){
            _pauseListenToSensorEvents();
            _stopNoise();
          }
        }
        insertData();
        getInfo(t);
        var _questionnaire = new ActivityQuestionnaire(onSubmit: onSubmit, activityData: _activity, timer: t);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => _questionnaire
        );
      }
    }
  }

  void _resetActivity(TimerService t){
    t.reset();
    if (!ESenseManager.connected) {
      null;
    } else {
      if (sampling){
        _pauseListenToSensorEvents();
      }
    }
    _gyroData = [];
    _accData =[];
  }

  Future<void> _neverSatisfied(TimerService t) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Please save your activity before disconnecting your device'),
          actions: <Widget>[
            FlatButton(
              child: Text('Go Back'),
              onPressed: () {
                t.start();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var timerService = TimerService.of(context);
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: timerService, // listen to ChangeNotifier
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      new Container(
                        width: 40,
                      ),
                      Text("Studying Activity Timer", style: TextStyle(fontSize: 30, color: Color(0xFF448AFF))),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '0${timerService.currentDuration.toString().split('.')[0]}',
                      style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 6.0),
                    ),
                    new Container(
                      height: 40.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Material(
                              child: Center(
                                child: Ink (
                                  decoration: ShapeDecoration(
                                    color: Color(0xFF448AFF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                  child:
                                  IconButton(
                                    icon: !timerService.isRunning ? Icon(Icons.play_arrow) : Icon(Icons.stop),
                                    iconSize: 50.0,
                                    color: Colors.white,
                                    tooltip: 'Start timer',
                                    onPressed: () => _handleActivity(timerService),
                                  ),
                                ),
                              ),
                            ),
                            Text(!timerService.isRunning ? 'Start' : 'End',
                                style: TextStyle(fontSize: 25)
                            )
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Material(
                              child: Center(
                                child: Ink (
                                  decoration: ShapeDecoration(
                                    color: Color(0xFF448AFF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                  child:
                                  IconButton(
                                    icon: Icon(Icons.settings_backup_restore),
                                    iconSize: 50.0,
                                    color: Colors.white,
                                    tooltip: 'Start again',
                                    onPressed: () => _resetActivity(timerService),
                                  ),
                                ),
                              ),
                            ),
                            Text('Reset',
                                style: TextStyle(fontSize: 25)
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FloatingActionButton.extended(
                      onPressed: () {
                        if (_deviceStatus == "connected"){
                          if (timerService.isRunning){
                            timerService.stop();
                            _neverSatisfied(timerService);
                          } else {
                            _disconnectESense();
                          }
                        } else {
                          _connectToESense();
                        }
                      },
                      label: _deviceStatus != "connected" ? Text('Connect') : Text('disconnect'),
                      icon: Icon(Icons.bluetooth_audio),
                      backgroundColor: Colors.pink,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}