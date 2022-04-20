// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pinned_info_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PinnedInfoHiveAdapter extends TypeAdapter<PinnedInfoHive> {
  @override
  final int typeId = 20;

  @override
  PinnedInfoHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PinnedInfoHive(
      pinnedBy: fields[0] as String,
      pinnedAt: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PinnedInfoHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.pinnedBy)
      ..writeByte(1)
      ..write(obj.pinnedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinnedInfoHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
