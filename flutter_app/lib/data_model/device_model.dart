class DeviceModel {
  String name;
  String firstPairing;

  DeviceModel({
    this.name,
    this.firstPairing,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'firstPairing': firstPairing,
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> json) => new DeviceModel(
      name: json["name"],
      firstPairing: json["firstPairing"],
  );

  @override
  String toString() {
    return 'Device{name: $name, firstPairing: $firstPairing}';
  }
}