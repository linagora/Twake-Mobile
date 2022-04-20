// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_role.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChannelRoleAdapter extends TypeAdapter<ChannelRole> {
  @override
  final int typeId = 13;

  @override
  ChannelRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChannelRole.owner;
      case 1:
        return ChannelRole.member;
      case 2:
        return ChannelRole.guest;
      case 3:
        return ChannelRole.bot;
      default:
        return ChannelRole.owner;
    }
  }

  @override
  void write(BinaryWriter writer, ChannelRole obj) {
    switch (obj) {
      case ChannelRole.owner:
        writer.writeByte(0);
        break;
      case ChannelRole.member:
        writer.writeByte(1);
        break;
      case ChannelRole.guest:
        writer.writeByte(2);
        break;
      case ChannelRole.bot:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
