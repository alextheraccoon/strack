import 'package:flutter/material.dart';
import 'login_model.dart';

class LoginResult extends StatelessWidget {
  LoginModel model;
  LoginResult({this.model});

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(title: Text('Successful')),
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(model.phoneId, style: TextStyle(fontSize: 22)),
            Text(model.username, style: TextStyle(fontSize: 22)),
            Text(model.gender, style: TextStyle(fontSize: 22)),
            Text(model.ageRange, style: TextStyle(fontSize: 22)),
            Text(model.status, style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
    ));
  }
}