// To parse this JSON data, do
//
//     final userModels = userModelsFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

UserModels userModelsFromJson(String str) =>
    UserModels.fromJson(json.decode(str));

String userModelsToJson(UserModels data) => json.encode(data.toJson());

class UserModels {
  final String lastName;
  final String id;
  final String firstName;
  final String status;

  UserModels({
    required this.lastName,
    required this.id,
    required this.firstName,
    required this.status,
  });

  factory UserModels.fromJson(Map<String, dynamic> json) => UserModels(
        lastName: json["last_name"],
        id: json["id"],
        firstName: json["first_name"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "last_name": lastName,
        "id": id,
        "first_name": firstName,
        "status": status,
      };
}
