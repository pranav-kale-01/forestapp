
import 'package:cloud_firestore/cloud_firestore.dart';

class TigerModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String userName;
  final String userEmail;
  final Timestamp? datetime;
  final GeoPoint location;
  final int noOfCubs;
  final int noOfTigers;
  final String remark;
  final String userContact;
  final String userImage;

  TigerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userName,
    required this.userEmail,
    this.datetime,
    required this.location,
    required this.noOfCubs,
    required this.noOfTigers,
    required this.remark,
    required this.userContact,
    required this.userImage,
  });
}
