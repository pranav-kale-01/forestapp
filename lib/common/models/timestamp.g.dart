// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timestamp.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeStampAdapter extends TypeAdapter<TimeStamp> {
  @override
  final int typeId = 2;

  @override
  TimeStamp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeStamp(
      seconds: fields[0] as int,
      nanoseconds: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TimeStamp obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.seconds)
      ..writeByte(1)
      ..write(obj.nanoseconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeStampAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
