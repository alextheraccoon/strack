import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutterapp/data_model/noise_model.dart';
import 'package:flutterapp/database/db.dart';


/// Example of a line chart rendered with dash patterns.
class NoiseChart extends StatefulWidget {
  final int id;

  NoiseChart(this.id,);

  _NoiseDataState createState() => _NoiseDataState();

}

class _NoiseDataState extends State<NoiseChart> with AutomaticKeepAliveClientMixin<NoiseChart>{
  List<NoiseModel> _noiseData = new List();
  List<NoiseDataTime> _maxDecibel = new List();
  List<NoiseDataTime> _meanDecibel = new List();
  static List<charts.Series<NoiseDataTime, int>> _seriesNoiseDataTime;

  @override
  bool get wantKeepAlive => true;

  _getNoiseData() async {
    var db = DBProvider.db;
    List<NoiseModel> noiseData = await db.noiseData();
    for (var i = 0; i < noiseData.length; i++){
      if (noiseData[i].activityId == widget.id){
        _noiseData.add(noiseData[i]);
      }
    }
  }


  _getNoiseDataTime(){
    for(var i = 0; i < _noiseData.length; i++){
      _maxDecibel.add(new NoiseDataTime(_noiseData[i].maxDecibel.floorToDouble(), i));
      _meanDecibel.add(new NoiseDataTime(_noiseData[i].meanDecibel.floorToDouble(), i));
//      _accZ.add(new NoiseDataTime(_noiseData[i].z/100, i));
//      print("AccX: ${_noiseData[i].x/1000}, $i");
      print("maxDecibel: ${_noiseData[i].maxDecibel}, $i");
      print("meanDecibel: ${_noiseData[i].meanDecibel}, $i");
    }
  }

  _generateData() async {
    _getNoiseData().then((value){
      _getNoiseDataTime();

      _seriesNoiseDataTime.add(
        charts.Series(
          colorFn: (__, _) =>
              charts.ColorUtil.fromDartColor(Color(0xff990099)),
          id: 'maxDecibel',
          data: _maxDecibel,
          domainFn: (NoiseDataTime value, _) => value.minute,
          measureFn: (NoiseDataTime value, _) => value.value,
        ),
      );

      _seriesNoiseDataTime.add(
        charts.Series(
          colorFn: (__, _) =>
              charts.ColorUtil.fromDartColor(Color(0xff109618)),
          id: 'meanDecibel',
          data: _meanDecibel,
          domainFn: (NoiseDataTime value, _) => value.minute,
          measureFn: (NoiseDataTime value, _) => value.value,
        ),
      );
//      _seriesNoiseDataTime.add(
//        charts.Series(
//          colorFn: (__, _) =>
//              charts.ColorUtil.fromDartColor(Color(0xffff9900)),
//          id: 'AccZ',
//          data: _accZ,
//          domainFn: (NoiseDataTime value, _) => value.minute,
//          measureFn: (NoiseDataTime value, _) => value.value,
//        ),
//      );
    });
  }

  @override
  void initState() {
    _generateData();
    _seriesNoiseDataTime = List<charts.Series<NoiseDataTime, int>>();
    super.initState();
  }

  Future<List<charts.Series<NoiseDataTime, int>>> _data = Future<List<charts.Series<NoiseDataTime, int>>>.delayed(
    Duration(seconds: 1),
        () => _seriesNoiseDataTime,
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
                      Text("Noise Data"),
                      Expanded(
                        child: charts.LineChart(
                            _seriesNoiseDataTime,
                            defaultRenderer: new charts.LineRendererConfig(
                                includeArea: false, stacked: true),
                            animate: true,
                            animationDuration: Duration(seconds: 3),
                            behaviors: [
                              new charts.ChartTitle('Time',
                                  behaviorPosition: charts.BehaviorPosition.bottom,
                                  titleOutsideJustification:charts.OutsideJustification.middleDrawArea),
                              new charts.ChartTitle('maxDecibel, meanDecibel',
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

class NoiseDataTime {
  final double value;
  final int minute;

  NoiseDataTime(this.value, this.minute);
}
