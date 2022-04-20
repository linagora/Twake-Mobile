// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_summary_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageSummaryHiveAdapter extends TypeAdapter<MessageSummaryHive> {
  @override
  final int typeId = 15;

  @override
  MessageSummaryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageSummaryHive(
      date: fields[0] as int,
      sender: fields[1] == null ? '0' : fields[1] as String,
      senderName: fields[2] == null ? 'Guest' : fields[2] as String,
      title: fields[3] as String,
      text: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MessageSummaryHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.sender)
      ..writeByte(2)
      ..write(obj.senderName)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageSummaryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
