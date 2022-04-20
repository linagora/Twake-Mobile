// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChannelHiveAdapter extends TypeAdapter<ChannelHive> {
  @override
  final int typeId = 6;

  @override
  ChannelHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChannelHive(
      id: fields[0] as String,
      name: fields[1] == null ? '' : fields[1] as String,
      icon: fields[2] as String?,
      description: fields[3] as String?,
      companyId: fields[4] as String,
      workspaceId: fields[5] as String,
      lastMessage: fields[10] as MessageSummary?,
      members: (fields[6] as List).cast<String>(),
      visibility: fields[8] == null
          ? ChannelVisibility.public
          : fields[8] as ChannelVisibility,
      lastActivity: fields[9] as int,
      membersCount: fields[7] == null ? 0 : fields[7] as int,
      role: fields[13] == null ? ChannelRole.member : fields[13] as ChannelRole,
      userLastAccess: fields[11] == null ? 0 : fields[11] as int,
      draft: fields[12] as String?,
      stats: fields[14] as ChannelStats?,
    );
  }

  @override
  void write(BinaryWriter writer, ChannelHive obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.companyId)
      ..writeByte(5)
      ..write(obj.workspaceId)
      ..writeByte(6)
      ..write(obj.members)
      ..writeByte(7)
      ..write(obj.membersCount)
      ..writeByte(8)
      ..write(obj.visibility)
      ..writeByte(9)
      ..write(obj.lastActivity)
      ..writeByte(10)
      ..write(obj.lastMessage)
      ..writeByte(11)
      ..write(obj.userLastAccess)
      ..writeByte(12)
      ..write(obj.draft)
      ..writeByte(13)
      ..write(obj.role)
      ..writeByte(14)
      ..write(obj.stats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
