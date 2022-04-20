// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account2workspace_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Account2WorkspaceHiveAdapter extends TypeAdapter<Account2WorkspaceHive> {
  @override
  final int typeId = 3;

  @override
  Account2WorkspaceHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account2WorkspaceHive(
      userId: fields[0] as String,
      workspaceId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Account2WorkspaceHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.workspaceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account2WorkspaceHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
