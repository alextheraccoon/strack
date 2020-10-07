import 'package:flutter/material.dart';
import 'model.dart';

class Result extends StatelessWidget {
  Model model;
  Result({this.model});

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(title: Text('Successful')),
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(model.duration, style: TextStyle(fontSize: 22)),
            Text(model.activity, style: TextStyle(fontSize: 22)),
            Text(model.engagement.toString(), style: TextStyle(fontSize: 22)),
            Text(model.absorption.toString(), style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
    ));
  }
}