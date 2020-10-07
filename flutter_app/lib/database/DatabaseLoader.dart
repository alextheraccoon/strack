
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutterapp/database/db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseLoader{

  Future _doneFuture;
  final String typeOfData;

  DatabaseLoader({
    this.typeOfData,
  }) {
    _doneFuture = _download(typeOfData);
  }
//  static final DatabaseLoader dl = DatabaseLoader()._();

  _download(data) async {
    var res = await getData(data);
    return res;
  }

  static getData(data) async {
    try {
      var db = DBProvider.db;
      print(db.database);
      print("hello");
      var typeOfData;
      if (data == "activity"){
        typeOfData = await db.queryActivities();
      } else if (data == "acc"){
        typeOfData = await db.queryAccData();
      } else if (data == "gyro") {
        typeOfData = await db.queryGyroData();
      } else if (data == "user"){
        typeOfData = await db.getUser(1);
      } else {
        typeOfData = await db.queryNoiseData();
      }
      return typeOfData;

    } catch (e) {
      print("Error $e");
    }
  }

  Future get initializationDone => _doneFuture;


}