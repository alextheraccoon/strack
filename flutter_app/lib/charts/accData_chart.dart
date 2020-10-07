import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutterapp/database/db.dart';
import 'package:flutterapp/data_model/accelerometer_model.dart';

/// Example of a line chart rendered with dash patterns.
class AccelerometerChart extends StatefulWidget {
  final int id;

  AccelerometerChart(this.id,);

  _AccDataState createState() => _AccDataState();

}

class _AccDataState extends State<AccelerometerChart> with AutomaticKeepAliveClientMixin<AccelerometerChart>{
  List<AccModel> _accData = new List();
  List<AccDataTime> _accX = new List();
  List<AccDataTime> _accY = new List();
  List<AccDataTime> _accZ = new List();
  static List<charts.Series<AccDataTime, int>> _seriesAccDataTime;

  @override
  bool get wantKeepAlive => true;

  _getAccData() async {
    var db = DBProvider.db;
    List<AccModel> accData = await db.accData();
    for (var i = 0; i < accData.length; i++){
      if (accData[i].activityId == widget.id){
        _accData.add(accData[i]);
      }
    }
  }


  _getAccDataTime(){
    for(var i = 0; i < _accData.length; i++){
      _accX.add(new AccDataTime(_accData[i].x/100, i));
      _accY.add(new AccDataTime(_accData[i].y/100, i));
      _accZ.add(new AccDataTime(_accData[i].z/100, i));
      print("AccX: ${_accData[i].x/1000}, $i");
      print("AccY: ${_accData[i].x/1000}, $i");
      print("AccZ: ${_accData[i].x/1000}, $i");
    }
  }

  _generateData() async {
    _getAccData().then((value){
        _getAccDataTime();

        _seriesAccDataTime.add(
          charts.Series(
            colorFn: (__, _) =>
                charts.ColorUtil.fromDartColor(Color(0xff990099)),
            id: 'AccX',
            data: _accX,
            domainFn: (AccDataTime value, _) => value.minute,
            measureFn: (AccDataTime value, _) => value.value,
          ),
        );

        _seriesAccDataTime.add(
          charts.Series(
            colorFn: (__, _) =>
                charts.ColorUtil.fromDartColor(Color(0xff109618)),
            id: 'AccY',
            data: _accY,
            domainFn: (AccDataTime value, _) => value.minute,
            measureFn: (AccDataTime value, _) => value.value,
          ),
        );
        _seriesAccDataTime.add(
          charts.Series(
            colorFn: (__, _) =>
                charts.ColorUtil.fromDartColor(Color(0xffff9900)),
            id: 'AccZ',
            data: _accZ,
            domainFn: (AccDataTime value, _) => value.minute,
            measureFn: (AccDataTime value, _) => value.value,
          ),
        );
    });
  }

  @override
  void initState() {
    _generateData();
    _seriesAccDataTime = List<charts.Series<AccDataTime, int>>();
    super.initState();
  }

  Future<List<charts.Series<AccDataTime, int>>> _data = Future<List<charts.Series<AccDataTime, int>>>.delayed(
    Duration(seconds: 1),
      () => _seriesAccDataTime,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return
      FutureBuilder(
        future: _data,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                children: <Widget>[
                Text("Accelerometer Data"),
                Expanded(
                  child: charts.LineChart(
                    _seriesAccDataTime,
                    defaultRenderer: new charts.LineRendererConfig(
                    includeArea: false, stacked: true),
                    animate: true,
                    animationDuration: Duration(seconds: 3),
                    behaviors: [
                      new charts.ChartTitle('Time',
                      behaviorPosition: charts.BehaviorPosition.bottom,
                      titleOutsideJustification:charts.OutsideJustification.middleDrawArea),
                      new charts.ChartTitle('AccX, AccY, AccZ',
                          behaviorPosition: charts.BehaviorPosition.start,
                          titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
                      new charts.SeriesLegend(),
                    ]
                  ),
                    )
                  ],
                ),
              )
            );
          }
        );
    }
}

class AccDataTime {
  final double value;
  final int minute;

  AccDataTime(this.value, this.minute);
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
