// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channels_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChannelsTypeAdapter extends TypeAdapter<ChannelsType> {
  @override
  final int typeId = 22;

  @override
  ChannelsType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChannelsType.directs;
      case 1:
        return ChannelsType.commons;
      default:
        return ChannelsType.directs;
    }
  }

  @override
  void write(BinaryWriter writer, ChannelsType obj) {
    switch (obj) {
      case ChannelsType.directs:
        writer.writeByte(0);
        break;
      case ChannelsType.commons:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelsTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
