// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_model_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConflictAdapter extends TypeAdapter<Conflict> {
  @override
  final int typeId = 1;

  @override
  Conflict read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conflict(
      id: fields[0] as String,
      range: fields[1] as String,
      round: fields[2] as String,
      bt: fields[3] as String,
      village_name: fields[4] as String,
      cNoName: fields[5] as String,
      conflict: fields[6] as String,
      person_name: fields[7] as String,
      person_age: fields[8] as String,
      person_gender: fields[9] as String,
      sp_causing_death: fields[10] as String,
      notes: fields[11] as String,
      imageUrl: fields[16] as String,
      userName: fields[17] as String,
      userEmail: fields[18] as String,
      datetime: fields[12] as TimeStamp?,
      location: fields[13] as GeoPoint,
      userContact: fields[14] as String,
      userImage: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Conflict obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.range)
      ..writeByte(2)
      ..write(obj.round)
      ..writeByte(3)
      ..write(obj.bt)
      ..writeByte(4)
      ..write(obj.village_name)
      ..writeByte(5)
      ..write(obj.cNoName)
      ..writeByte(6)
      ..write(obj.conflict)
      ..writeByte(7)
      ..write(obj.person_name)
      ..writeByte(8)
      ..write(obj.person_age)
      ..writeByte(9)
      ..write(obj.person_gender)
      ..writeByte(10)
      ..write(obj.sp_causing_death)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.datetime)
      ..writeByte(13)
      ..write(obj.location)
      ..writeByte(14)
      ..write(obj.userContact)
      ..writeByte(15)
      ..write(obj.userImage)
      ..writeByte(16)
      ..write(obj.imageUrl)
      ..writeByte(17)
      ..write(obj.userName)
      ..writeByte(18)
      ..write(obj.userEmail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConflictAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
