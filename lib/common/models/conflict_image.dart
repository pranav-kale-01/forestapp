import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'conflict_image.g.dart';

@HiveType(typeId:4)
class ConflictImage {
  @HiveField(0)
  Uint8List conflictImage;

  ConflictImage( {
    required this.conflictImage,
});
}