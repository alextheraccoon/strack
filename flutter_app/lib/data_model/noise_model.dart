class NoiseModel {
  double maxDecibel;
  double meanDecibel;
  int activityId;

  NoiseModel({
    this.maxDecibel,
    this.meanDecibel,
    this.activityId,
  });

  Map<String, dynamic> toMap() {
    return {
      'maxDecibel': maxDecibel,
      'meanDecibel': meanDecibel,
      'activityId': activityId
    };
  }

  factory NoiseModel.fromMap(Map<String, dynamic> json) => new NoiseModel(
      maxDecibel: json["maxDecibel"],
      meanDecibel: json["meanDecibel"],
      activityId: json["activityId"]
  );

  @override
  String toString() {
    return 'Noise{maxDecibel: $maxDecibel, meanDecibel: $meanDecibel, activityId : $activityId}';
  }
}