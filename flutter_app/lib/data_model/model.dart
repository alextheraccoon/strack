

import 'package:flutterapp/data_model/accelerometer_model.dart';
import 'package:flutterapp/data_model/gyroscope_model.dart';

class Model {
  String date;
  String duration;
  String activity;
  String engagement;
  String absorption;
  int activityId;

  Model({
    this.date,
    this.duration,
    this.activity,
    this.engagement,
    this.absorption,
    this.activityId
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'duration': duration,
      'activity': activity,
      'engagement': engagement,
      'absorption': absorption,
      'activityId': activityId
    };
  }

  factory Model.fromMap(Map<String, dynamic> json) => new Model(
      date: json["date"],
      duration: json["duration"],
      activity: json["activity"],
      engagement: json['engagement'],
      absorption: json['absorption'],
      activityId: json['activityId']
  );

  @override
  String toString() {
    return 'Activity{date: $date, duration: $duration, activity: $activity, engagement: $engagement, absorption: $absorption, activityId: $activityId}';
  }
}