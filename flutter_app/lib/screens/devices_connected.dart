import 'package:flutter/material.dart';
import 'package:flutterapp/data_model/accelerometer_model.dart';
import 'package:flutterapp/data_model/device_model.dart';
import 'package:flutterapp/data_model/gyroscope_model.dart';
import 'package:flutterapp/database/db.dart';
import 'package:meta/meta.dart';
import '../utility/category.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:esense_flutter/esense.dart';

const _padding = EdgeInsets.all(16.0);

class DevicesList extends StatefulWidget {
  final Category category;

  const DevicesList({
    @required this.category,
  }) : assert(category != null);

  @override
  _DevicesListState createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {

  String _deviceName = 'Unknown';
  double _voltage = -1;
  String _deviceStatus = '';
  bool sampling = false;
  String _event = '';
  String _button = 'not pressed';
////  // the name of the eSense device to connect to -- change this to your own device.
  String eSenseName = 'eSense-0283';
  List<DeviceModel> _devices = [];

  _getDevices() async {
    var db = DBProvider.db;
    var devices = await db.deviceData();
    return devices;
  }

  @override
  void initState() {
    _getDevices().then((value){
      setState(() {
        _devices = value;
      });
    });
    super.initState();
  }


  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: ListView(
            children: [

              Padding(
                padding: EdgeInsets.only(left: 20, top: 30, bottom: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Paired Devices ", style: TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.redAccent
                    ),),
                  ],
                ),
              ),

              _devices.length != 0 ? Column(
                children:
                List.generate(_devices.length,(index){
                  return Container(
                    width: MediaQuery.of(context).size.width - 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Divider(height: 10.0, color: Colors.white,),
                        DeviceItem( _devices[index]),
                        new Divider(height: 20.0, color: Colors.redAccent, thickness: 1.0,),
                      ],
                    ),
                  );
                }),
              ) :
              Container(
                height: 500,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("No devices registered", style: TextStyle(fontSize: 20),),
                        Container(height: 20,),
                        Text("Devices that will be used during activities ",
                          style: TextStyle(fontSize: 16), softWrap: true, textAlign: TextAlign.center,),
                        Text("will be listed here once connected.",
                          style: TextStyle(fontSize: 16), softWrap: true, textAlign: TextAlign.center,)
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
    );
  }
}

class DeviceItem extends StatelessWidget{
  DeviceModel device;

  DeviceItem(this.device);


  @override
  Widget build(BuildContext context) {
    final fullWidth = MediaQuery.of(context).size.width;
    return Container(
      width: fullWidth,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
//          Text(activity.activityId.toString(), style: TextStyle(fontSize: 16), textAlign: TextAlign.left,),
          Icon(Icons.headset_mic, size: 35, color: Colors.redAccent,),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("${device.name}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
              Text("Paired on: ${device.firstPairing}", style: TextStyle(fontSize: 16,), textAlign: TextAlign.left,)
            ],
          )

        ],
      ),
    );
  }

}