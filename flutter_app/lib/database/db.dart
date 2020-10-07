import 'package:flutterapp/data_model/accelerometer_model.dart';
import 'package:flutterapp/data_model/device_model.dart';
import 'package:flutterapp/data_model/gyroscope_model.dart';
import 'package:flutterapp/data_model/login_model.dart';
import 'package:flutterapp/data_model/model.dart';
import 'package:flutterapp/data_model/noise_model.dart';
import 'package:flutterapp/data_model/timestamp_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';


class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  Database _database;
  Transaction txn;

  Future<Database> get database async {

    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();

    return _database;
  }

  static initDB() async {
    var databasesPath = await getApplicationDocumentsDirectory();
    String path = join(databasesPath.path, 'my_database.db');

//    await deleteDatabase(path);
    try {
//      await Sqflite.devSetDebugModeOn(true);
      final database = openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
        path,
        onCreate: (db, version) async {

          await db.execute(
            "CREATE TABLE USER(phoneId STRING, username STRING PRIMARY KEY, status STRING, gender STRING, ageRange STRING, earbudsName STRING, userId INTEGER)",
          );
          await db.execute(
              "CREATE TABLE ACTIVITY(date STRING, duration STRING, activity STRING, engagement STRING, absorption STRING, activityId INTEGER PRIMARY KEY)"
          );
          await db.execute(
              "CREATE TABLE ACCDATA(x INTEGER, y INTEGER, z INTEGER, timestamp STRING, packetId INTEGER, activityId INTEGER)"
          );
          await db.execute(
              "CREATE TABLE GYRODATA(x INTEGER, y INTEGER, z INTEGER, timestamp STRING, packetId INTEGER, activityId INTEGER)"
          );
          await db.execute(
              "CREATE TABLE NOISEDATA(maxDecibel DOUBLE, meanDecibel DOUBLE, activityId INTEGER)"
          );
          await db.execute(
              "CREATE TABLE DEVICE(name STRING PRIMARY KEY, firstPairing STRING)"
          );
        },
        // Set the version. This executes the onCreate function and provides a
        // path to perform database upgrades and downgrades.
        version: 1,
      );
      return database;
    } finally {

    }

  }

  Future<List<LoginModel>> getAllUser() async {
    final db = await database;
    var res = await db.query("USER");
    List<LoginModel> list =
    res.isNotEmpty ? res.map((c) => LoginModel.fromMap(c)).toList() : [];
    return list;
  }

  queryActivities() async {
    final db = await database;
    var res = await db.query("ACTIVITY");
    return res;
  }

  queryAccData() async {
    final db = await database;
    var res = await db.query("ACCDATA");
    return res;
  }

  queryGyroData() async {
    final db = await database;
    var res = await db.query("GYRODATA");
    return res;
  }

  queryUser() async {
    final db = await database;
    var res = await db.query("USER");
    return res;
  }

  queryNoiseData() async {
    final db = await database;
    var res = await db.query("NOISEDATA");
    return res;
  }

  addUser(LoginModel model) async {
    final db = await database;

    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.rawInsert('INSERT INTO USER(phoneId, username, status, gender, ageRange, earbudsName, userId) VALUES(?, ?, ?, ?, ?, ?, ?)',
          [model.phoneId, model.username, model.status, model.gender, model.ageRange, model.earbudsName, model.userId]);
      await batch.commit(noResult: true);
//      await txn.rawInsert(
//          'INSERT INTO USER(phoneId, username, status, gender, ageRange, earbudsName, userId) VALUES(?, ?, ?, ?, ?, ?, ?)',
//          [model.phoneId, model.username, model.status, model.gender, model.ageRange, model.earbudsName, model.userId]);
    });

  }

  addActivity(Model model) async {
    final db = await database;
//    await db.insert(
//      'ACTIVITY',
//      model.toMap(),
//      conflictAlgorithm: ConflictAlgorithm.replace,
//    );
    await db.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO ACTIVITY(date, duration, activity, engagement, absorption, activityId) VALUES(?, ?, ?, ?, ?, ?)',
          [model.date, model.duration, model.activity, model.engagement, model.absorption, model.activityId]);
    });
  }

  addAccData(AccModel model) async{
    final db = await database;
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.rawInsert(
          'INSERT INTO ACCDATA(x, y, z, timestamp, packetId, activityId) VALUES(?, ?, ?, ?, ?, ?)',
          [model.x, model.y, model.z, model.timestamp, model.packetId, model.activityId]);
      await batch.commit(noResult: true);
    });
  }

  addAccelerometer(List<AccModel> elems){
    for (var i = 0; i < elems.length; i++){
      addAccData(elems[i]);
    }
  }

  addGyroData(GyroModel model) async {
    final db = await database;
//    await db.insert(
//      'GYRODATA',
//      model.toMap(),
//      conflictAlgorithm: ConflictAlgorithm.replace,
//    );
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.rawInsert(
          'INSERT INTO GYRODATA(x, y, z, timestamp, packetId, activityId) VALUES(?, ?, ?, ?, ?, ?)',
          [model.x, model.y, model.z, model.timestamp, model.packetId, model.activityId]);
      await batch.commit(noResult: true);
    });
  }

  addGyroscope(List<GyroModel> elems){
    for (var i =0; i < elems.length; i++){
      addGyroData(elems[i]);
    }
  }

  addNoiseData(NoiseModel model) async {
    final db = await database;
//    await db.insert(
//      'TIMESTAMP',
//      model.toMap(),
//      conflictAlgorithm: ConflictAlgorithm.replace,
//    );
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.rawInsert(
          'INSERT INTO NOISEDATA(maxDecibel, meanDecibel, activityId) VALUES(?, ?, ?)',
          [model.maxDecibel, model.meanDecibel, model.activityId]);
      await batch.commit(noResult: true);
    });
  }

  addNoise(List<NoiseModel> elems) {
    for (var i =0; i < elems.length; i++){
      addNoiseData(elems[i]);
    }
  }

  addDevice(DeviceModel model) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO DEVICE(name, firstPairing) VALUES(?, ?)',
          [model.name, model.firstPairing]);
    });
  }

  Future<void> updateUser(LoginModel user) async {
    // Get a reference to the database.
    final db = await database;
    await db.update(
      'USER',
      user.toMap(),
      where: "userId = ?",
      whereArgs: [user.userId],
    );
  }

  Future<List<LoginModel>> users() async {
    // Get a reference to the database.
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('USER');

    return List.generate(maps.length, (i) {
      return LoginModel(
        phoneId: maps[i]['phoneId'],
        username: maps[i]['username'],
        gender: maps[i]['gender'],
        ageRange: maps[i]['ageRange'],
        status: maps[i]['status'],
        earbudsName: maps[i]['earbudsName'],
        userId: maps[i]['userId']
      );
    });
  }

  Future<List<Model>> activities() async {
    // Get a reference to the database.
    final Database db = await database;
    // Query the table for all The activities
    final List<Map<String, dynamic>> maps = await db.query('ACTIVITY');
    return List.generate(maps.length, (i) {
      return Model(
          date: maps[i]['date'],
          duration: maps[i]['duration'],
          activity: maps[i]['activity'],
          engagement: maps[i]['engagement'].toString(),
          absorption: maps[i]['absorption'].toString(),
          activityId: maps[i]['activityId'],
      );
    });
  }

  Future<List<AccModel>> accData() async {
    // Get a reference to the database.
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ACCDATA');
    return List.generate(maps.length, (i) {
      return AccModel(
          x: maps[i]['x'],
          y: maps[i]['y'],
          z: maps[i]['z'],
          timestamp: maps[i]['timestamp'],
          packetId: maps[i]['packetId'],
          activityId: maps[i]['activityId'],
      );
    });
  }

  Future<List<GyroModel>> gyroData() async {
    // Get a reference to the database.
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('GYRODATA');
    return List.generate(maps.length, (i) {
      return GyroModel(
        x: maps[i]['x'],
        y: maps[i]['y'],
        z: maps[i]['z'],
        timestamp: maps[i]['timestamp'],
        packetId: maps[i]['packetId'],
        activityId: maps[i]['activityId'],
      );
    });
  }

  Future<List<NoiseModel>> noiseData() async {
    // Get a reference to the database.
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('NOISEDATA');
    return List.generate(maps.length, (i) {
      return NoiseModel(
        maxDecibel: maps[i]['maxDecibel'],
        meanDecibel: maps[i]['meanDecibel'],
        activityId: maps[i]['activityId'],
      );
    });
  }

  Future<List<DeviceModel>> deviceData() async {
    // Get a reference to the database.
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('DEVICE');
    return List.generate(maps.length, (i) {
      return DeviceModel(
        name: maps[i]['name'],
        firstPairing: maps[i]['firstPairing'],
      );
    });
  }


  Future<LoginModel> getUser(int id) async {
    final db = await database;
    List<Map> res = await db.query(
        "USER",
        where: "userId = ?",
        whereArgs: [id]);
    return res.isNotEmpty ? LoginModel.fromMap(res.first) : null;
  }

  deleteUser() async {
    final db = await database;
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.delete('USER', where: 'userId = ?', whereArgs: [1]);
      batch.delete("ACTIVITY");
      batch.delete("ACCDATA");
      batch.delete("GYRODATA");
      batch.delete("NOISEDATA");
      batch.delete("DEVICE");
      await batch.commit();
    });
  }

  deleteDevice() async {
    final db = await database;
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.delete('DEVICE', where: 'name = ?', whereArgs: [1]);
      await batch.commit();
    });
  }

  Future<AccModel> getAccData(int id) async {
    final db = await database;
    List<Map> res = await db.query(
        "ACCDATA",
        where: "activityId = ?",
        whereArgs: [id]);
    return res.isNotEmpty ? AccModel.fromMap(res.first) : null;
  }

  Future<GyroModel> getGyroData(int id) async {
    final db = await database;
    List<Map> res = await db.query(
        "GYRODATA",
        where: "activityId = ?",
        whereArgs: [id]);
    return res.isNotEmpty ? GyroModel.fromMap(res.first) : null;
  }

  Future<NoiseModel> getNoiseData(int id) async {
    final db = await database;
    List<Map> res = await db.query(
        "NOISEDATA",
        where: "activityId = ?",
        whereArgs: [id]);
    return res.isNotEmpty ? NoiseModel.fromMap(res.first) : null;
  }

  Future close() async {
    _database = null;
    db.close();
  }

}

