import 'package:flutter/material.dart';
import 'package:flutterapp/form/dropdown_item.dart';
import 'package:flutterapp/form/number_selector.dart';
import '../data_model/model.dart';
import 'mytextformfield.dart';
import 'package:validators/validators.dart' as validator;
import '../data_model/result.dart';
import 'package:flutterapp/utility/timer.dart';
import 'package:flutterapp/activity/activity_details.dart';
import 'package:flutterapp/database/db.dart';


class ActivityForm extends StatefulWidget {

  final TimerService timer;

  const ActivityForm({
    @required this.timer,
  }) : assert(timer != null);

  @override
  _ActivityFormState createState() => _ActivityFormState();

}


class _ActivityFormState extends State<ActivityForm> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final _formKey = GlobalKey<FormState>();
  Model model = Model();

  final _categoryNames = <DropdownItem>[
    DropdownItem('Watch video lessons', Icons.live_tv),
    DropdownItem('Attend courses online', Icons.laptop),
    DropdownItem('Watch tutorial online', Icons.help),
    DropdownItem('Listen to recorded audio lessons', Icons.headset),
    DropdownItem('Writing/Reading', Icons.book),
    DropdownItem('Other', Icons.add),
  ];

  String _engageValue = 0.toString();
  String _absorptionValue = 0.toString();
  String _duration;
  int _pauses;
  DropdownItem _current;
  List<DropdownMenuItem<DropdownItem>> _dropdownMenuItems;

  @override
  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_categoryNames);
    _current = _dropdownMenuItems[0].value;
    super.initState();
  }


  void _handleRadioValueChange1(String value) {
    setState(() {
      _engageValue = value;
    });
  }

  void _handleRadioValueChange2(String value) {
    setState(() {
      _absorptionValue = value;
    });
  }

  List<DropdownMenuItem<DropdownItem>> buildDropdownMenuItems(List names) {
    List<DropdownMenuItem<DropdownItem>> items = List();
    for (DropdownItem item in names) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(item.icon),
              Container(width: 20,),
              Text(item.name),
            ],),
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

  Future<void> _saveActivity(Model model) async {
    var db = DBProvider.db;
    db.addActivity(model);
    print(await db.activities());
  }

  final myController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final halfMediaWidth = MediaQuery
        .of(context)
        .size
        .width / 2.0;

//
    final firstInput = Container(
      height: 90,
      alignment: Alignment.topCenter,
      width: halfMediaWidth,
      child: Scaffold(
        body: TextField(
          decoration: const InputDecoration(
            labelText: "Activity Name"
          ),
          controller: myController,
        ),
      ),
    );


    final nameActivity = Container(
      child: Column(
        children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  width: 40,
                ),
                Text(
                  "Activity Name",
                  style: TextStyle(fontSize: 18, color: Color(0xFF0ABC9B)),
                  textAlign: TextAlign.left,
                ),
              ]
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  width: 40,
                ),
                firstInput,
              ]
          ),
        ],
      ),
    );

    final secondInput = Container(
      height: 70,
      child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Duration",
                    style: TextStyle(fontSize: 18, color: Color(0xFF0ABC9B)),
                    textAlign: TextAlign.left,

                  ),
                  Text(
                    '${widget.timer.currentDuration.toString().split('.')[0]}',
                    style: TextStyle(fontSize: 30),
                  )
                ],
              )
            ],
          )
      ),
    );

    final pauses = Container(
      height: 50,
      child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: 40,
              ),
              Text(
                "Pauses",
                style: TextStyle(fontSize: 18, color: Color(0xFF0ABC9B)),
                textAlign: TextAlign.left,
              ),
              new Container(
                width: 40,
              ),
              Text(
                '${widget.timer.pauses}',
                style: TextStyle(fontSize: 20),
              )
            ],
          )
      ),
    );

    final activities = Container(
      height: 100,
      child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Activities Accomplished",
                    style: TextStyle(fontSize: 18, color: Color(0xFF0ABC9B)),
                    textAlign: TextAlign.left,
                  ),
                  DropdownButton(
                    value: _current,
                    items: _dropdownMenuItems,
                    onChanged: onChangeDropdownItem,
                  ),
                ],
              )
            ],
          )
      ),
    );

    final engagementLevel = Container(
      height: 100,
      child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Engagement level",
                    style: TextStyle(fontSize: 18, color: Color(0xFF0ABC9B)),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        NumberSelector(value1: 1.toString(), groupValue: _engageValue, f: _handleRadioValueChange1),
                        NumberSelector(value1: 2.toString(), groupValue: _engageValue, f: _handleRadioValueChange1),
                        NumberSelector(value1: 3.toString(), groupValue: _engageValue, f: _handleRadioValueChange1),
                        NumberSelector(value1: 4.toString(), groupValue: _engageValue, f: _handleRadioValueChange1),
                        NumberSelector(value1: 5.toString(), groupValue: _engageValue, f: _handleRadioValueChange1)
                        ]
                  )
                ]
              ),
            ],
          ),
      )
    );

    final challenging = Container(
        height: 100,
        child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: 40,
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "How challengin it was",
                      style: TextStyle(fontSize: 18, color: Color(0xFF0ABC9B)),
                      textAlign: TextAlign.left,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          NumberSelector(value1: 1.toString(), groupValue: _absorptionValue, f: _handleRadioValueChange2),
                          NumberSelector(value1: 2.toString(), groupValue: _absorptionValue, f: _handleRadioValueChange2),
                          NumberSelector(value1: 3.toString(), groupValue: _absorptionValue, f: _handleRadioValueChange2),
                          NumberSelector(value1: 4.toString(), groupValue: _absorptionValue, f: _handleRadioValueChange2),
                          NumberSelector(value1: 5.toString(), groupValue: _absorptionValue, f: _handleRadioValueChange2)
                        ]
                    )
                  ]
              ),
            ],
          ),
        )
    );

    final button = RaisedButton(
      color: Color(0xFF0ABC9B),
      onPressed: () {
        _duration = widget.timer.currentDuration.toString().split('.')[0];
        _pauses = widget.timer.pauses;
//        this.model.activityName = myController.text;
        this.model.date = DateTime.now().toString();
        this.model.duration = _duration;
        this.model.activity = _current.name;
        this.model.engagement = _engageValue.toString();
        this.model.absorption = _absorptionValue.toString();
        if (_duration != null && _pauses != null &&
            _current!= null && _engageValue != null &&
            _absorptionValue != null && myController.text != null) {
          print(_engageValue);
          print("all fields are valid");
//          _formKey.currentState.save();
          _saveActivity(model);
        }

//          Navigator.push(
//              context,
//              MaterialPageRoute(
//                  builder: (context) => Result(model: this.model)));

//        } else {
//          Fluttertoast.showToast(msg: 'Missing fields!',toastLength: Toast.LENGTH_SHORT);
//        }
        widget.timer.reset();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ActivityDetails(model: model, prev: 0,)),
        );
      },
      child: Text(
        'Save Activity',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );


    return Scaffold(
        appBar: AppBar(
          title: Text("Save Activity"),
          backgroundColor: Color(0xFF0ABC9B),
        ),
        body: ListView(
            children: <Widget>[
              Center(
                  child: Column(
                    children: <Widget>[
                      new Container(
                        height: 40,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            width: 25,
                          ),
                          Text(
                            "Enter the following details",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ],
                      ),
                      new Container(
                        height: 15,
                      ),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              new Container(
                                height: 10,
                              ),
                              nameActivity,
                              secondInput,
                              pauses,
                              activities,
                              engagementLevel,
                              challenging,
                              button,
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