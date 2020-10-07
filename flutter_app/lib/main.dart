import 'dart:convert';
import 'package:flutter/material.dart';
import 'utility/category_route.dart';
import 'utility/timer.dart';
import 'database/db.dart';
import 'data_model/login_model.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'package:flutterapp/data_model/text_storage.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterapp/database/db.dart';
import 'package:intl/intl.dart';

/// The function that is called when main.dart is run.
///


void main() {
  final timerService = TimerService();
  runApp(
      TimerServiceProvider(
          service: timerService,
          child: MyApp()
      ));
}


class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "STRACK",
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.grey[600],
        ),
        // This colors the [InputOutlineBorder] when it is selected
        primaryColor: Colors.grey[500],
        textSelectionHandleColor: Colors.pink,
      ),
      home: FutureBuilder<List<LoginModel>>(
              future: DBProvider.db.getAllUser(),
              builder: (BuildContext context, AsyncSnapshot<List<LoginModel>> snapshot) {
                return CategoryRoute();
              }
              )
    );
  }
}