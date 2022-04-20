// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountHiveAdapter extends TypeAdapter<AccountHive> {
  @override
  final int typeId = 2;

  @override
  AccountHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountHive(
      id: fields[0] as String,
      email: fields[1] as String,
      firstName: fields[2] as String?,
      lastName: fields[3] as String?,
      username: fields[4] as String?,
      verified: fields[12] as int?,
      deleted: fields[13] as int?,
      picture: fields[5] as String?,
      providerId: fields[6] as String?,
      status: fields[7] as String?,
      language: fields[8] as String?,
      lastActivity: fields[9] as int?,
      recentWorkspaceId: fields[10] as String?,
      recentCompanyId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AccountHive obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.picture)
      ..writeByte(6)
      ..write(obj.providerId)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.language)
      ..writeByte(9)
      ..write(obj.lastActivity)
      ..writeByte(10)
      ..write(obj.recentWorkspaceId)
      ..writeByte(11)
      ..write(obj.recentCompanyId)
      ..writeByte(12)
      ..write(obj.verified)
      ..writeByte(13)
      ..write(obj.deleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
