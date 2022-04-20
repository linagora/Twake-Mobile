// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'globals_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GlobalsHiveAdapter extends TypeAdapter<GlobalsHive> {
  @override
  final int typeId = 8;

  @override
  GlobalsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GlobalsHive(
      host: fields[0] as String,
      channelsType:
          fields[5] == null ? ChannelsType.commons : fields[5] as ChannelsType,
      token: fields[6] as String,
      fcmToken: fields[7] as String,
      userId: fields[8] as String?,
      companyId: fields[1] as String?,
      workspaceId: fields[2] as String?,
      channelId: fields[3] as String?,
      threadId: fields[4] as String?,
      clientId: fields[9] as String?,
      oidcAuthority: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GlobalsHive obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.host)
      ..writeByte(1)
      ..write(obj.companyId)
      ..writeByte(2)
      ..write(obj.workspaceId)
      ..writeByte(3)
      ..write(obj.channelId)
      ..writeByte(4)
      ..write(obj.threadId)
      ..writeByte(5)
      ..write(obj.channelsType)
      ..writeByte(6)
      ..write(obj.token)
      ..writeByte(7)
      ..write(obj.fcmToken)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.clientId)
      ..writeByte(10)
      ..write(obj.oidcAuthority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobalsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
