import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../utility/category.dart';
import 'package:flutterapp/form/number_selector.dart';
import '../form/mytextformfield.dart';
import '../data_model/login_model.dart';
import '../form/dropdown_item.dart';
import '../data_model/login_result.dart';
import '../form/activity_form.dart';

const _padding = EdgeInsets.all(16.0);

class EditProfile extends StatefulWidget {

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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


  void _handleRadioValueChange(String value) {
    setState(() {
      _phoneId = value;
    });
  }

  void _handleRadioValueChange2(String value) {
    setState(() {
      _gender = value;
    });
  }

  List<DropdownMenuItem<DropdownItem>> _dropdownMenuItemsAges;
  DropdownItem _selectedAge;

  List<DropdownMenuItem<DropdownItem>> _dropdownMenuItemsStatus;
  DropdownItem _selectedStatus;


  @override
  void initState() {
    _dropdownMenuItemsAges = buildDropdownMenuItems(_ageRanges);
    _selectedAge = _dropdownMenuItemsAges[0].value;
    _dropdownMenuItemsStatus = buildDropdownMenuItems(_statusOptions);
    _selectedStatus = _dropdownMenuItemsStatus[0].value;
    super.initState();
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
              item.icon != null ? Icon(item.icon) : Icon(Icons.fiber_manual_record),
              Container(width: 20,),
              Text(item.name),
            ],),
        ),
      );
    }
    return items;
  }

  onChangeDropdownItemAge(DropdownItem selected) {
    setState(() {
      _selectedAge = selected;
    });
  }

  onChangeDropdownItemStatus(DropdownItem selected) {
    setState(() {
      _selectedStatus = selected;
    });
  }



  @override
  Widget build(BuildContext context) {

    final halfMediaWidth = MediaQuery
        .of(context)
        .size
        .width / 2.0;

    final phoneId = Container(
        height: 100,
        child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: 40,
              ),
              Container(
                width: 200,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "Phone Id",
                        style: TextStyle(fontSize: 18, color: Color(0xFFFFA41C), fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            NumberSelector(value1: "IOS", groupValue: _phoneId, f: _handleRadioValueChange),
                            NumberSelector(value1: "Android", groupValue: _phoneId, f: _handleRadioValueChange),
                          ]
                      )
                    ]
                ),
              )
            ],
          ),
        ));

    final firstInput = Container(
      height: 60,
      alignment: Alignment.topCenter,
      width: halfMediaWidth,
      child: Scaffold(
        body: MyTextFormField(
          hintText: 'username',
          validator: (String value) {
            if (value.isEmpty) {
              return 'Enter a username for your profile';
            }
            return null;
          },
          onSaved: (String value) {
            model.username = value;
          },
        ),
      ),
    );

    final username = Container(
      child: Column(
        children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  width: 40,
                ),
                Text(
                  "Username",
                  style: TextStyle(fontSize: 18, color: Color(0xFFFFA41C), fontWeight: FontWeight.bold),
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

    final gender = Container(
        height: 100,
        child: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: 40,
              ),
              Container(
                width: 200,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "Gender",
                        style: TextStyle(fontSize: 18, color: Color(0xFFFFA41C), fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                width: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Age Range",
                    style: TextStyle(fontSize: 18, color: Color(0xFFFFA41C), fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  DropdownButton(
                    value: _selectedAge,
                    items: _dropdownMenuItemsAges,
                    onChanged: onChangeDropdownItemAge,
                  ),
                ],
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
                width: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Status",
                    style: TextStyle(fontSize: 18, color: Color(0xFFFFA41C), fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  DropdownButton(
                    value: _selectedStatus,
                    items: _dropdownMenuItemsStatus,
                    onChanged: onChangeDropdownItemStatus,
                  ),
                ],
              )
            ],
          )
      ),
    );

    Future<void> _neverSatisfied() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Profile Modified'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Your information has been updated correctly'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
//                  Navigator.of(context).pop();
                  var count = 0;
                  Navigator.popUntil(context, (route) {
                    return count++ == 2;
                  });
                },
              ),
            ],
          );
        },
      );
    }

    final button = RaisedButton(
      color: Color(0xFFFFA41C),
      onPressed: () {
        model.phoneId = _phoneId;
        model.gender = _gender;
        model.ageRange = _selectedAge.name;
        model.status = _selectedStatus.name;
        if (_formKey.currentState.validate()) {
          if (_phoneId != null && _gender != null &&
              _ageRange != null && _status != null) {

          }
          _formKey.currentState.save();
          _neverSatisfied();
        }
      },
      child: Text(
        'Edit Profile',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );

    return Scaffold(
        body: ListView(
            children: <Widget>[
              Container(height: 20,),
              Row(
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      iconSize: 30.0,
                      color: Color(0xFFFFA41C),
                      tooltip: 'Go to Homepage',
                      onPressed: () {
                        var count = 0;
                        Navigator.popUntil(context, (route) {
                          return count++ == 1;
                        });
                      }
                  ),
                  Container(width: 15,),
                  Text("Edit Profile", style: TextStyle(fontSize: 30, color: Color(0xFFFFA41C)),)
                ],
              ),
              Center(
                  child: Column(
                    children: <Widget>[
                      Container(height: 20,),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              phoneId,
                              new Divider(height: 15.0, color: Colors.white),
                              username,
                              new Divider(height: 15.0, color: Colors.white),
                              gender,
                              new Divider(height: 15.0, color: Colors.white),
                              ageRange,
                              status,
                              new Divider(height: 15.0, color: Colors.white),
                              button
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