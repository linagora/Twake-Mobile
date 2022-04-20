// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthenticationHiveAdapter extends TypeAdapter<AuthenticationHive> {
  @override
  final int typeId = 1;

  @override
  AuthenticationHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthenticationHive(
      token: fields[0] as String,
      refreshToken: fields[1] as String,
      expiration: fields[2] as int,
      refreshExpiration: fields[3] as int,
      consoleToken: fields[4] as String,
      idToken: fields[5] as String,
      consoleRefresh: fields[6] as String,
      consoleExpiration: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AuthenticationHive obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.token)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.expiration)
      ..writeByte(3)
      ..write(obj.refreshExpiration)
      ..writeByte(4)
      ..write(obj.consoleToken)
      ..writeByte(5)
      ..write(obj.idToken)
      ..writeByte(6)
      ..write(obj.consoleRefresh)
      ..writeByte(7)
      ..write(obj.consoleExpiration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthenticationHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
