// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BadgeHiveAdapter extends TypeAdapter<BadgeHive> {
  @override
  final int typeId = 9;

  @override
  BadgeHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BadgeHive(
      type: fields[0] as BadgeType,
      id: fields[1] as String,
      count: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, BadgeHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
