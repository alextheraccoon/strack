import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutterapp/data_model/gyroscope_model.dart';
import 'package:flutterapp/database/db.dart';
import 'package:flutterapp/data_model/accelerometer_model.dart';

/// Example of a line chart rendered with dash patterns.
class GyroscopeChart extends StatefulWidget {
  final int id;

  GyroscopeChart(this.id,);

  _GyroDataState createState() => _GyroDataState();

}

class _GyroDataState extends State<GyroscopeChart> with AutomaticKeepAliveClientMixin<GyroscopeChart>{
  List<GyroModel> _gyroData = new List();
  List<GyroDataTime> _gyroX = new List();
  List<GyroDataTime> _gyroY = new List();
  List<GyroDataTime> _gyroZ = new List();
  static List<charts.Series<GyroDataTime, int>> _seriesGyroDataTime;

  @override
  bool get wantKeepAlive => true;

  _getGyroData() async {
    var db = DBProvider.db;
    List<GyroModel> gyroData = await db.gyroData();
    for (var i = 0; i < gyroData.length; i++){
      if (gyroData[i].activityId == widget.id){
        _gyroData.add(gyroData[i]);
      }
    }
  }

  _getGyroDataTime(){
    for(var i = 0; i < _gyroData.length; i++){
      _gyroX.add(new GyroDataTime(_gyroData[i].x/10, i));
      _gyroY.add(new GyroDataTime(_gyroData[i].y/10, i));
      _gyroZ.add(new GyroDataTime(_gyroData[i].z/10, i));
      print("GyroX: ${_gyroData[i].x/1000}, $i");
      print("GyroY: ${_gyroData[i].x/1000}, $i");
      print("GyroZ: ${_gyroData[i].x/1000}, $i");
    }

  }

  _generateData(){
    _getGyroData().then((value){
      _getGyroDataTime();

      _seriesGyroDataTime.add(
        charts.Series(
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff990099)),
          id: 'GyroX',
          data: _gyroX,
          domainFn: (GyroDataTime value, _) => value.minute,
          measureFn: (GyroDataTime value, _) => value.value,
        ),
      );
      _seriesGyroDataTime.add(
        charts.Series(
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff109618)),
          id: 'GyroY',
          data: _gyroY,
          domainFn: (GyroDataTime value, _) => value.minute,
          measureFn: (GyroDataTime value, _) => value.value,
        ),
      );
      _seriesGyroDataTime.add(
        charts.Series(
          colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xffff9900)),
          id: 'GyroZ',
          data: _gyroZ,
          domainFn: (GyroDataTime value, _) => value.minute,
          measureFn: (GyroDataTime value, _) => value.value,
        ),
      );
    });
  }

  @override
  void initState() {
    _generateData();
    _seriesGyroDataTime = List<charts.Series<GyroDataTime, int>>();
    super.initState();
  }

  Future<List<charts.Series<GyroDataTime, int>>> _data = Future<List<charts.Series<GyroDataTime, int>>>.delayed(
    Duration(seconds: 1),
        () => _seriesGyroDataTime,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: _data,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                children: <Widget>[
                  Text("Gyroscope Data"),
                  Expanded(
                    child: charts.LineChart(
                        _seriesGyroDataTime,
                        defaultRenderer: new charts.LineRendererConfig(
                            includeArea: false, stacked: true),
                        animate: true,
                        animationDuration: Duration(seconds: 3),
                        behaviors: [
                          new charts.ChartTitle('Time',
                              behaviorPosition: charts.BehaviorPosition.bottom,
                              titleOutsideJustification: charts.OutsideJustification
                                  .middleDrawArea),
                          new charts.ChartTitle('GyroX, GyroY, GyroZ',
                              behaviorPosition: charts.BehaviorPosition.start,
                              titleOutsideJustification: charts.OutsideJustification
                                  .middleDrawArea),
                          new charts.SeriesLegend(),
                        ]
                    ),
                  )
                ],
              ),
            ),
          );
        }
      );
  }
}

class GyroDataTime {
  final double value;
  final int minute;

  GyroDataTime(this.value, this.minute);
}



/// Creates a [LineChart] with sample data and no transition.
//  factory DashPatternLineChart.withSampleData() {
//    return new DashPatternLineChart(
//      _createSampleData(),
//      _getId(),
//      // Disable animations for image tests.
//      animate: false,
//    );
//  }

//  @override
//  Widget build(BuildContext context) {
//    return new charts.LineChart(seriesList, animate: animate);
//  }
//
//
//
//  static int _getId(){
//    return id;
//  }
//
//
//  /// Create three series with sample hard coded data.
//  static List<charts.Series<int, int>> _createSampleData() {
//    final myFakeDesktopData = [
//      new LinearSales(0, 5),
//      new LinearSales(1, 25),
//      new LinearSales(2, 100),
//      new LinearSales(3, 75),
//    ];
//
//    var myFakeTabletData = [
//      new LinearSales(0, 10),
//      new LinearSales(1, 50),
//      new LinearSales(2, 200),
//      new LinearSales(3, 150),
//    ];
//
//    var myFakeMobileData = [
//      new LinearSales(0, 15),
//      new LinearSales(1, 75),
//      new LinearSales(2, 300),
//      new LinearSales(3, 225),
//    ];
//
//    return [
//      new charts.Series<int, int>(
//        id: 'Desktop',
//        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//        domainFn: (LinearSales sales, _) => sales.year,
//        measureFn: (LinearSales sales, _) => sales.sales,
//        data: myFakeDesktopData,
//      ),
//      new charts.Series<LinearSales, int>(
//        id: 'Tablet',
//        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
////        dashPattern: [2, 2],
//        domainFn: (LinearSales sales, _) => sales.year,
//        measureFn: (LinearSales sales, _) => sales.sales,
//        data: myFakeTabletData,
//      ),
//      new charts.Series<LinearSales, int>(
//        id: 'Mobile',
//        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
////        dashPattern: [8, 3, 2, 3],
//        domainFn: (LinearSales sales, _) => sales.year,
//        measureFn: (LinearSales sales, _) => sales.sales,
//        data: myFakeMobileData,
//      )
//    ];
//  }
//}
//
///// Sample linear data type.
