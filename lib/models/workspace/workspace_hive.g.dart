// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkspaceHiveAdapter extends TypeAdapter<WorkspaceHive> {
  @override
  final int typeId = 5;

  @override
  WorkspaceHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkspaceHive(
      id: fields[0] as String,
      name: fields[1] == null ? '' : fields[1] as String,
      logo: fields[2] as String?,
      companyId: fields[3] as String,
      totalMembers: fields[4] == null ? 0 : fields[4] as int,
      role:
          fields[5] == null ? WorkspaceRole.member : fields[5] as WorkspaceRole,
    );
  }

  @override
  void write(BinaryWriter writer, WorkspaceHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.logo)
      ..writeByte(3)
      ..write(obj.companyId)
      ..writeByte(4)
      ..write(obj.totalMembers)
      ..writeByte(5)
      ..write(obj.role);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
