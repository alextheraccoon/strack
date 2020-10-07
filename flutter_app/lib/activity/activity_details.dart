import 'package:flutter/material.dart';
import 'package:flutterapp/charts/gyroData_chart.dart';
import 'package:flutterapp/charts/noiseData_chart.dart';
import 'package:flutterapp/data_model/model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutterapp/charts/accData_chart.dart';

const _padding = EdgeInsets.fromLTRB(25.0, 45.0, 25.0, 20.0);

class ActivityDetails extends StatefulWidget {

  final Model model;
  // if called from activity_form = 0, if called from activity_item = 1
  final int prev;

  const ActivityDetails({
    @required this.model,
    @required this.prev
  }) : assert(model != null);

  @override
  _ActivityDetailsState createState() => _ActivityDetailsState();
}


class _ActivityDetailsState extends State<ActivityDetails> with AutomaticKeepAliveClientMixin<ActivityDetails>{

  @override
  bool get wantKeepAlive => true;

  Color _color;

  Icon _findIcon(String name){
    if (name == 'Smile'){
      return Icon(Icons.tag_faces, color: Colors.white, size: 35);
    } else if (name == 'Nod'){
      return Icon(Icons.thumb_up,color: Colors.white, size: 35,);
    } else if (name == 'Yawn'){
      return Icon(Icons.thumb_down, color: Colors.white, size: 35);
    } else if (name == 'Move head left/rigth'){
      return Icon(Icons.swap_horiz, color: Colors.white, size: 35);
    } else if (name == 'Talk'){
      return Icon(Icons.record_voice_over, color: Colors.white, size: 35);
    } else {
      return Icon(Icons.not_interested, color: Colors.white, size: 35);
    }
  }

  static List<String> _monthsList = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ];

  var _day;
  var _month;
  var _year;

  @override
  void initState() {
    super.initState();
    var date = widget.model.date.toString().split('.')[0];
    var splitted = date.split('-');
    _day = splitted[2];
    _month = _monthsList[int.parse(splitted[1]) -1];
    _year = splitted[0];

  }

  @override
  Widget build(BuildContext context) {

     _color = Color(0xff9962D0);

    final date = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
//        Container(
//          width: 220,
//          child: Text("Date", style: TextStyle(fontSize: 20, color: _color),),
//        ),
        Icon(Icons.calendar_today, size:40,),
        Container(height: 20,),
        Center(
          child: Text("$_day $_month, $_year", style: TextStyle(fontSize: 25, letterSpacing: 1), textAlign: TextAlign.left,),
        ),
      ],
    );

    final duration = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Center(
              child: Text("0${widget.model.duration}", style: TextStyle(fontSize: 50,), textAlign: TextAlign.left,),
            ),
            Container(height: 10,),
            Container(
              child: Text("Duration", style: TextStyle(fontSize: 25, color: _color, letterSpacing: 1,),),
            ),
          ],
        )


      ],
    );

    final activities = Container(
      width: MediaQuery.of(context).size.width,
      height: 110,
      color: Color(0xff9962D0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _findIcon(widget.model.activity),
                    Container(width: 30,),
                    Text(widget.model.activity, style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1
                    ),),
                  ],
                ),
            ],
          )
        ],
      ),
    );



    final absorption = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(widget.model.absorption, style: TextStyle(fontSize: 35,), textAlign: TextAlign.left,),
        Container(height: 30,),
        Text("Absorption", style: TextStyle(fontSize: 18, color: _color, fontWeight: FontWeight.bold, letterSpacing: 1),),
      ],
    );

    final engagement = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(widget.model.engagement, style: TextStyle(fontSize: 35,), textAlign: TextAlign.left,),
        Container(height: 30,),
        Text("Engagement ", style: TextStyle(fontSize: 18, color: _color, fontWeight: FontWeight.bold, letterSpacing: 1),),
      ],
    );

    return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFFCA90E5),
      //backgroundColor: Color(0xff308e1c),
              bottom: TabBar(
                indicatorColor: Color(0xff9962D0),
                tabs: [
                  Tab(
                    icon: Icon(Icons.signal_cellular_4_bar),
                  ),
                  Tab(icon: Icon(Icons.pie_chart)),
                  Tab(icon: Icon(Icons.volume_up)),
                  Tab(icon: Icon(Icons.show_chart)),

                ],
              ),
              title: Text('Activity Overview'),
            ),
            body: TabBarView(
              children: [
                new AccelerometerChart(widget.model.activityId),
                new GyroscopeChart(widget.model.activityId),
                new NoiseChart(widget.model.activityId),
                Container(
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
//                      Container(width: 40,),
                      Column(
                        children: <Widget>[
                          new Divider(height: 50.0, color: Colors.white),
                          duration,
                          new Divider(height: 50.0, color: Color(0xff9962D0)),
                          activities,
                          new Divider(height: 40.0, color: Colors.white),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              engagement,
                              Container(width: 70,),
                              absorption
                            ],
                          ),
                          new Divider(height: 70.0, color:Color(0xff9962D0),),
                          date,

                        ],
                      ),
                    ],
                  )
                ),
              ]
            )
          )
      );
  }
}
