

class StampModel {
  String timestamp;
  int packetId;
  int activityId;

  StampModel({
    this.timestamp,
    this.packetId,
    this.activityId,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'packetId': packetId,
      'activityId': activityId
    };
  }

  factory StampModel.fromMap(Map<String, dynamic> json) => new StampModel(
      timestamp: json["timestamp"],
      packetId: json["packetId"],
      activityId: json["activityId"]
  );

  @override
  String toString() {
    return 'Timestamp{timestamp: $timestamp, packetId: $packetId, activityId : $activityId}';
  }
}