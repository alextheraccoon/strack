import 'package:flutter/material.dart';
import 'package:flutterapp/data_model/accelerometer_model.dart';
import 'package:flutterapp/data_model/gyroscope_model.dart';
import 'package:meta/meta.dart';
import '../utility/category.dart';
import 'package:flutterapp/data_model/model.dart';
import 'package:flutterapp/database/db.dart';
import 'package:flutterapp/activity/activity_item.dart';

const _padding = EdgeInsets.all(16.0);

class Overview extends StatefulWidget {
  final Category category;

  const Overview({
    @required this.category,
  }) : assert(category != null);

  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> with SingleTickerProviderStateMixin{
  static List<Model> _activities;
  Animation<double> animation;
  AnimationController _controller;
  String i;
  Map<String, int> _monthsMap = Map.fromIterables(_monthsList, _values );
  static List<String> _monthsList = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ];
  static List<int> _values = [0,0,0,0,0,0,0,0,0,0,0,0];

  _getActivities() async {
    var db = DBProvider.db;
    List<Model > activities = await db.activities();
    _activities = activities;
  }

  _getAccData() async {
    var db = DBProvider.db;
    List<AccModel> accData = await db.accData();
    print(accData);
  }

  _getGyroData() async {
    var db = DBProvider.db;
    List<GyroModel> accData = await db.gyroData();
    print(accData);
  }


  @override
  void initState(){
    _getActivities().then((value){
      _activities != null ? print(_activities) : print("no activities");
      _controller = AnimationController(duration:const Duration(seconds: 1), vsync: this);
      animation = Tween<double>(begin: 0, end: _activities.length.ceilToDouble()).animate(_controller)
        ..addListener((){
          setState((){
            // The state that has changed here is the animation objects value
            i = animation.value.toStringAsFixed(0);
          });
        });
      _controller.forward();
    });
    _getAccData();
    _getGyroData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  String _monthName;
  String _year;

  int _getMonth(Model activity){
    print(activity);
    var dates = activity.date.split("-");
    var month = int.parse(dates[1]);
    _year = dates[0];
    _monthName = _monthsList[month -1];
    print(_monthsMap[_monthName]);
    if (_monthsMap[_monthName] == 0){
      _monthsMap[_monthName] = 1;
      return 1;
    } else {
      return 0;
    }

  }

  Future<List<Model>> _activitiesRegistered = Future<List<Model>>.delayed(
    Duration(seconds: 1),
        () => _activities,
  );

  @override
  Widget build(BuildContext context) {

    final activitiesCompleted =
    Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 200,
            color: Color(0xFFFFA41C),
            child:
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Center(
                        child: Text(
                          i, style: TextStyle(fontSize: 60,color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                    ],
                  ),
                  Container(
                    child: Text("Total Activities",
                      style: TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 1),),
                  ),
                ],
              ),
          ),
          Container(height: 40,),
          _activities.length != 0 ? Column(
            children:
            List.generate(_activities.length,(index){
              return Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ActivityItem( _activities[_activities.length - 1 - index]),
                    new Divider(height: 20.0, color: Color(0xFFFFA41C), thickness: 1.0,),
                  ],
                ),
              );
            }),
          ) : Text("No activities registered"),
        ],
      ),
    );


    return FutureBuilder(
        future: _activitiesRegistered,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          Widget child;
          if (snapshot.hasData){
            child = Scaffold(
                body: ListView(
                  children: <Widget>[
                    Column(
                        children: <Widget>[
                          activitiesCompleted,
                        ]
                    )
                  ],
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

