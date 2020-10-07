import 'package:flutter/material.dart';
//
class NumberSelector extends StatelessWidget {
  final String value1;
  final String groupValue;
  final Function f;

  NumberSelector({
    @required this.value1,
    @required this.groupValue,
    @required this.f
  });

  @override
  Widget build(BuildContext context) {
    return  Column(
        children: <Widget>[
          new Radio(
            value: value1,
            groupValue: groupValue,
            onChanged: f
          ),
          new Text(
            value1.toString(),
            style: new TextStyle(fontSize: 14.0),
          ),
        ],
      );
  }
}