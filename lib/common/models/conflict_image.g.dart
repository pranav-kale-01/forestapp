// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConflictImageAdapter extends TypeAdapter<ConflictImage> {
  @override
  final int typeId = 4;

  @override
  ConflictImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConflictImage(
      conflictImage: fields[0] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, ConflictImage obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.conflictImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConflictImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
