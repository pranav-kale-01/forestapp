import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:hive/hive.dart';

part 'geopoint.g.dart';

@HiveType( typeId: 3)
class GeoPoint extends firestore.GeoPoint {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  GeoPoint({
    required this.latitude,
    required this.longitude
  }) : super( latitude, longitude );
}