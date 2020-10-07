import 'package:flutter/material.dart';
import '../data_model/model.dart';
import 'package:flutterapp/activity/activity_details.dart';
import 'package:intl/intl.dart';

class ActivityItem extends StatelessWidget{
  Model activity;

  ActivityItem(this.activity);


  IconData _findIcon(){
    var act = activity.activity;
    if (act == 'Smile'){
      return Icons.tag_faces;
    } else if (act == 'Nod'){
      return Icons.thumb_up;
    } else if (act == 'Yawn'){
      return Icons.thumb_down;
    } else if (act == 'Move head left/rigth'){
      return Icons.swap_horiz;
    } else if (act == 'Talk'){
      return Icons.record_voice_over;
    } else {
      return Icons.not_interested;
    }
  }

  List<String> _monthsList = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ];

  var _day;
  var _month;
  var _year;

  _getDate(){
    var date = this.activity.date.toString().split('.')[0];
    var splitted = date.split('-');
    _day = splitted[2];
    _month = _monthsList[int.parse(splitted[1]) -1];
    _year = splitted[0];
    return Text("$_day $_month, $_year", style: TextStyle(fontSize: 16, letterSpacing: 1), textAlign: TextAlign.left,);
  }


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
          Icon(_findIcon(), size: 30,),
          _getDate(),
          IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              iconSize: 16.0,
              color: Colors.black,
              tooltip: 'Go to activity details',
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActivityDetails(model: activity, prev: 1)),
                );
              }
          ),
        ],
      ),
    );
  }

}