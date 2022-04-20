// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageHiveAdapter extends TypeAdapter<MessageHive> {
  @override
  final int typeId = 7;

  @override
  MessageHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageHive(
      id: fields[0] as String,
      threadId: fields[1] as String,
      channelId: fields[2] as String,
      userId: fields[3] as String,
      createdAt: fields[4] as int,
      updatedAt: fields[5] as int,
      responsesCount: fields[6] == null ? 0 : fields[6] as int,
      username: fields[13] as String?,
      text: fields[7] == null ? '' : fields[7] as String,
      blocks: (fields[8] as List).cast<dynamic>(),
      reactions:
          fields[11] == null ? [] : (fields[11] as List).cast<Reaction>(),
      files: (fields[9] as List?)?.cast<dynamic>(),
      delivery:
          fields[18] == null ? Delivery.delivered : fields[18] as Delivery,
      firstName: fields[14] as String?,
      lastName: fields[15] as String?,
      picture: fields[16] as String?,
      draft: fields[17] as String?,
    )
      ..subtype = fields[10] as MessageSubtype?
      ..pinnedInfo = fields[12] as PinnedInfoHive?;
  }

  @override
  void write(BinaryWriter writer, MessageHive obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.threadId)
      ..writeByte(2)
      ..write(obj.channelId)
      ..writeByte(3)
      ..write(obj.userId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.responsesCount)
      ..writeByte(7)
      ..write(obj.text)
      ..writeByte(8)
      ..write(obj.blocks)
      ..writeByte(9)
      ..write(obj.files)
      ..writeByte(10)
      ..write(obj.subtype)
      ..writeByte(11)
      ..write(obj.reactions)
      ..writeByte(12)
      ..write(obj.pinnedInfo)
      ..writeByte(13)
      ..write(obj.username)
      ..writeByte(14)
      ..write(obj.firstName)
      ..writeByte(15)
      ..write(obj.lastName)
      ..writeByte(16)
      ..write(obj.picture)
      ..writeByte(17)
      ..write(obj.draft)
      ..writeByte(18)
      ..write(obj.delivery);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
