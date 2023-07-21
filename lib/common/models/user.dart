import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String aadharImageUrl;
  final String aadharNumber;
  final String contactNumber;
  final String email;
  final String forestIDImageUrl;
  final String imageUrl;
  final String name;
  final int forestId;
  final double longitude;
  final double latitude;
  final int radius;
  String? password;
  final Timestamp? datetime;

  User({
    required this.aadharNumber,
    required this.aadharImageUrl,
    required this.name,
    required this.email,
    required this.forestIDImageUrl,
    required this.imageUrl,
    required this.contactNumber,
    required this.forestId,
    required this.longitude,
    required this.latitude,
    required this.radius,
    this.datetime,
    this.password,
  });
}