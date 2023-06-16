import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String aadharImageUrl;
  final String aadharNumber;
  final String contactNumber;
  final String email;
  final String forestID;
  final String forestIDImageUrl;
  final String imageUrl;
  final String name;
  final String password;
  final Timestamp? datetime;

  UserModel({
    required this.aadharNumber,
    required this.aadharImageUrl,
    required this.password,
    required this.name,
    required this.email,
    required this.forestIDImageUrl,
    required this.forestID,
    required this.imageUrl,
    required this.contactNumber,
    this.datetime,
  });
}