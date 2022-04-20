// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_stats_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChannelStatsHiveAdapter extends TypeAdapter<ChannelStatsHive> {
  @override
  final int typeId = 14;

  @override
  ChannelStatsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChannelStatsHive(
      members: fields[0] as int,
      messages: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ChannelStatsHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.members)
      ..writeByte(1)
      ..write(obj.messages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelStatsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
