// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyHiveAdapter extends TypeAdapter<CompanyHive> {
  @override
  final int typeId = 4;

  @override
  CompanyHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanyHive(
      id: fields[0] as String,
      name: fields[1] as String,
      totalMembers: fields[3] == null ? 0 : fields[3] as int,
      logo: fields[2] as String?,
      selectedWorkspace: fields[5] as String?,
      role: fields[4] as CompanyRole,
    );
  }

  @override
  void write(BinaryWriter writer, CompanyHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.logo)
      ..writeByte(3)
      ..write(obj.totalMembers)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.selectedWorkspace);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
