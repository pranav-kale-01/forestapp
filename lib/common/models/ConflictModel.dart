import 'package:cloud_firestore/cloud_firestore.dart';

class ConflictModel {
  final String id;
  final String range;
  final String round;
  final String bt;
  final String village_name;
  final String cNoName;
  final String pincodeName;
  final String conflict;
  final String person_name;
  final String person_age;
  final String person_gender;
  final String sp_causing_death;
  final String notes;
  final Timestamp? datetime;
  final GeoPoint location;
  final String userContact;
  final String userImage;
  final String imageUrl;
  final String userName;
  final String userEmail;

  ConflictModel({
    required this.id,
    required this.range,
    required this.round,
    required this.bt,
    required this.village_name,
    required this.cNoName,
    required this.pincodeName,
    required this.conflict,
    required this.person_name,
    required this.person_age,
    required this.person_gender,
    required this.sp_causing_death,
    required this.notes,
    required this.imageUrl,
    required this.userName,
    required this.userEmail,
    this.datetime,
    required this.location,
    required this.userContact,
    required this.userImage,
  });
}
