import 'geopoint.dart';
import 'package:hive/hive.dart';
import 'timestamp.dart';

part 'conflict_model_hive.g.dart';

@HiveType( typeId: 1 )
class Conflict {
  @HiveField(0)
  String id;

  @HiveField(1)
  final String range;

  @HiveField(2)
  final String round;

  @HiveField(3)
  final String bt;

  @HiveField(4)
  final String village_name;

  @HiveField(5)
  final String cNoName;

  @HiveField(6)
  final String pincodeName;

  @HiveField(7)
  final String conflict;

  @HiveField(8)
  final String person_name;

  @HiveField(9)
  final String person_age;

  @HiveField(10)
  final String person_gender;

  @HiveField(11)
  final String sp_causing_death;

  @HiveField(12)
  final String notes;

  @HiveField(13)
  final TimeStamp? datetime;


  @HiveField(14)
  final GeoPoint location;

  @HiveField(15)
  final String userContact;

  @HiveField(16)
  final String userImage;

  @HiveField(17)
  String imageUrl;

  @HiveField(18)
  final String userName;

  @HiveField(19)
  final String userEmail;

  Conflict({
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

  Map<String, dynamic> get toMap => {
      'id': id,
      "range" : range,
      "round" : round,
      'bt' : bt,
      "village_name" : village_name,
      "c_no_name" : cNoName,
      "conflict" : conflict,
      "person_name" : person_name,
      "pincode_name" : pincodeName,
      "person_age" : person_age,
      "person_gender" : person_gender  ,
      "sp_causing_death" : sp_causing_death,
      "notes" : notes,
      'imageUrl': imageUrl,
      'location': location,
      'user_name': userName,
      'user_email': userEmail,
      'user_contact': userContact,
      'user_imageUrl': imageUrl,
      'createdAt': datetime,
  };
}
