// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_role.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkspaceRoleAdapter extends TypeAdapter<WorkspaceRole> {
  @override
  final int typeId = 16;

  @override
  WorkspaceRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WorkspaceRole.moderator;
      case 1:
        return WorkspaceRole.member;
      default:
        return WorkspaceRole.moderator;
    }
  }

  @override
  void write(BinaryWriter writer, WorkspaceRole obj) {
    switch (obj) {
      case WorkspaceRole.moderator:
        writer.writeByte(0);
        break;
      case WorkspaceRole.member:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
