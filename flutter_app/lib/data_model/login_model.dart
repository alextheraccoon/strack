

class LoginModel {
  String phoneId;
  String username;
  String gender;
  String ageRange;
  String status;
  String earbudsName;
  int userId;

  LoginModel({
    this.phoneId,
    this.username,
    this.gender,
    this.ageRange,
    this.status,
    this.earbudsName,
    this.userId
  });

  Map<String, dynamic> toMap() {
    return {
      'phoneId': phoneId,
      'username': username,
      'status': status,
      'gender': gender,
      'ageRange': ageRange,
      'earbudsName' : earbudsName,
      'userId': userId
    };
  }

  factory LoginModel.fromMap(Map<String, dynamic> json) => new LoginModel(
    phoneId: json["phoneId"],
    username: json["username"],
    status: json["status"],
    gender: json["gender"],
    ageRange: json["ageRange"],
    earbudsName: json["earbudsName"],
    userId: json['userId']
  );

  @override
  String toString() {
    return 'User{phoneId: $phoneId, username: $username, status: $status, gender: $gender, ageRange: $ageRange, earbudsName: $earbudsName, userId: $userId}';
  }
}