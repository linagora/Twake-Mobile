// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_visibility.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChannelVisibilityAdapter extends TypeAdapter<ChannelVisibility> {
  @override
  final int typeId = 12;

  @override
  ChannelVisibility read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChannelVisibility.public;
      case 1:
        return ChannelVisibility.private;
      case 2:
        return ChannelVisibility.direct;
      default:
        return ChannelVisibility.public;
    }
  }

  @override
  void write(BinaryWriter writer, ChannelVisibility obj) {
    switch (obj) {
      case ChannelVisibility.public:
        writer.writeByte(0);
        break;
      case ChannelVisibility.private:
        writer.writeByte(1);
        break;
      case ChannelVisibility.direct:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelVisibilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
