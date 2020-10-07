import 'package:flutter/material.dart';
import 'package:flutterapp/data_model/accelerometer_model.dart';
import 'package:flutterapp/data_model/noise_model.dart';
import 'package:flutterapp/form/number_selector.dart';
import 'package:flutterapp/form/dropdown_item.dart';
import 'package:flutterapp/data_model/model.dart';
import 'package:flutterapp/database/db.dart';
import 'package:flutterapp/utility/timer.dart';
import 'package:flutterapp/data_model/gyroscope_model.dart';

typedef void MyFormCallback(bool result);

class ActivityQuestionnaire extends StatefulWidget {
  final MyFormCallback onSubmit;
  final Model activityData;
  final TimerService timer;

  ActivityQuestionnaire({this.onSubmit, this.activityData, this.timer});

  @override
  QuestionnaireState createState() => QuestionnaireState();
}


class QuestionnaireState extends State<ActivityQuestionnaire>{

  String engageValue = "";
  String absorptionValue ="";
  DropdownItem _current;
  List<DropdownMenuItem<DropdownItem>> _dropdownMenuItems;
  final _categoryNames = <DropdownItem>[
    DropdownItem('Smile', Icons.tag_faces),
    DropdownItem('Nod', Icons.thumb_up),
    DropdownItem('Yawn', Icons.thumb_down),
    DropdownItem('Move head left/rigth', Icons.swap_horiz),
    DropdownItem('Talk', Icons.record_voice_over),
    DropdownItem('Baseline', Icons.not_interested),
  ];
  bool _complete = true;

  @override
  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_categoryNames);
    _current = null;
    super.initState();
  }

  void _handleRadioValueChange1(String value) {
    setState(() {
      engageValue = value;
    });
  }

  void _handleRadioValueChange2(String value) {
    setState(() {
      absorptionValue = value;
    });
  }

  List<DropdownMenuItem<DropdownItem>> buildDropdownMenuItems(List names) {
    List<DropdownMenuItem<DropdownItem>> items = List();
    for (DropdownItem item in names) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Container(
            width: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(item.icon),
                Container(width: 20,),
                Text(item.name),
              ],
            ),
          ),
        ),
      );
    }
    return items;
  }

  onChangeDropdownItem(DropdownItem value){
    setState(() {
      _current = value;
    });
  }


  saveInfo() async {
    var db = DBProvider.db;
    if (_current != null && engageValue != ""
          && absorptionValue != ""){
      widget.activityData.activity = _current.name;
      widget.activityData.engagement = engageValue;
      widget.activityData.absorption = absorptionValue;
      db.addActivity(widget.activityData);
      widget.timer.reset();
      widget.onSubmit(true);
      Navigator.pop(context);

    } else {
      print("form not completed");
      setState(() {
        _complete = false;
      });
    }

//    List<Model> _activities = await db.activities();
//    List<AccModel> _accData = await db.accData();
//    List<GyroModel> _gyroData = await db.gyroData();
//    List<NoiseModel> _noiseData = await db.noiseData();
//    print("ACTIVITIES: $_activities");
//    print("ACCDATA: $_accData");
//    print("GYRODATA: $_gyroData");
//    print("NOISEDATA: $_noiseData");
    print("activity saved!");
  }

  @override
  Widget build(BuildContext context) {

    final _engagement = Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(width: 20,),
              Text(
                "Engagement level",
                style: TextStyle(fontSize: 18, color: Color(0xFF448AFF), fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Text(
              "What was your engagement level during this activity?",
              style: TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.left,
            ),
          ),

          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                NumberSelector(value1: 1.toString(), groupValue: engageValue, f: _handleRadioValueChange1),
                NumberSelector(value1: 2.toString(), groupValue: engageValue, f: _handleRadioValueChange1),
                NumberSelector(value1: 3.toString(), groupValue: engageValue, f: _handleRadioValueChange1),
                NumberSelector(value1: 4.toString(), groupValue: engageValue, f: _handleRadioValueChange1),
                NumberSelector(value1: 5.toString(), groupValue: engageValue, f: _handleRadioValueChange1)
              ]
          ),
        ],
      ),
    );

    final _challenging = Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(width: 20,),
              Text(
                "Absorption",
                style: TextStyle(fontSize: 18, color: Color(0xFF448AFF), fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
            child: Text(
              "I was totally immersed in this activity",
              style: TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.left,
            ),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                NumberSelector(value1: 1.toString(), groupValue: absorptionValue, f: _handleRadioValueChange2),
                NumberSelector(value1: 2.toString(), groupValue: absorptionValue, f: _handleRadioValueChange2),
                NumberSelector(value1: 3.toString(), groupValue: absorptionValue, f: _handleRadioValueChange2),
                NumberSelector(value1: 4.toString(), groupValue: absorptionValue, f: _handleRadioValueChange2),
                NumberSelector(value1: 5.toString(), groupValue: absorptionValue, f: _handleRadioValueChange2)
              ]
          ),
        ],
      ),
    );

    final _activityType = Container(
//      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(width: 20,),
              Text(
                "Activity Type",
                style: TextStyle(fontSize: 18, color: Color(0xFF448AFF), fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Text(
              "Select the type of activity you just completed",
              style: TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Container(width: 20,),
                DropdownButton(
                  hint: Text("Please select one option"),
                  value: _current,
                  items: _dropdownMenuItems,
                  onChanged: onChangeDropdownItem,
                  elevation: 16,
                  underline: Container(
                    height: 1,
                    color: Color(0xFF448AFF),
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );


    return SimpleDialog(
      title: Text("How was your activity?"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: EdgeInsets.fromLTRB(5, 30, 0, 20),
      children: <Widget>[
        Container(
          height: 590,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _engagement,
                new Divider(height: 30.0, color: Colors.white),
                _challenging,
                new Divider(height: 30.0, color: Colors.white),
                _activityType,
                new Divider(height: 35.0, color: Colors.white),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: RaisedButton(
                        onPressed: () {
                          saveInfo();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5.0),
                        ),
                        child: new Text("Submit", style: TextStyle(fontSize: 16, color: Colors.white),),
//                      borderSide: BorderSide(color: Colors.white),
                        color: Color(0xFF448AFF),
//                    shape: ,
                      ),
                    )
                  ],
                ),
//                !_complete ?
//                Container(
//                  width: 500,
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    crossAxisAlignment: CrossAxisAlignment.center,
//                      children: <Widget>[
//                        Column(
//                          children: <Widget>[
//                            Text("Not all fields have been filled!", style: TextStyle(color: Colors.red),
//      //                        textAlign: TextAlign.center,
//                            ),
//                            Text("Please complete them all.", style: TextStyle(color: Colors.red),
//      //                          textAlign: TextAlign.center
//                            )
//                          ],
//                        ),
//                      ],
//                  ))
//                    : Container(),
              ]
          ),
        )
        ],
      );
  }

}