

class AccModel {
  int x;
  int y;
  int z;
  String timestamp;
  int packetId;
  int activityId;

  AccModel({
    this.x,
    this.y,
    this.z,
    this.timestamp,
    this.packetId,
    this.activityId,
  });

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'timestamp': timestamp,
      'packetId' : packetId,
      'activityId': activityId
    };
  }

  factory AccModel.fromMap(Map<String, dynamic> json) => new AccModel(
      x: json["x"],
      y: json["y"],
      z: json["z"],
      timestamp: json["timestamp"],
      packetId: json["packetId"],
      activityId: json["activityId"]
  );

  @override
  String toString() {
    return 'Accelerometer{x: $x, y: $y, z: $z, timestamp: $timestamp, packetId: $packetId, activityId : $activityId}';
  }
}