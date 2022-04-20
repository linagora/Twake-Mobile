// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_location_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SharedLocationHiveAdapter extends TypeAdapter<SharedLocationHive> {
  @override
  final int typeId = 10;

  @override
  SharedLocationHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedLocationHive(
      id: fields[0] as int?,
      companyId: fields[1] as String,
      workspaceId: fields[2] as String,
      channelId: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SharedLocationHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.companyId)
      ..writeByte(2)
      ..write(obj.workspaceId)
      ..writeByte(3)
      ..write(obj.channelId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedLocationHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
