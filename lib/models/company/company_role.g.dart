// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_role.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyRoleAdapter extends TypeAdapter<CompanyRole> {
  @override
  final int typeId = 17;

  @override
  CompanyRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CompanyRole.owner;
      case 1:
        return CompanyRole.admin;
      case 2:
        return CompanyRole.member;
      case 3:
        return CompanyRole.guest;
      default:
        return CompanyRole.owner;
    }
  }

  @override
  void write(BinaryWriter writer, CompanyRole obj) {
    switch (obj) {
      case CompanyRole.owner:
        writer.writeByte(0);
        break;
      case CompanyRole.admin:
        writer.writeByte(1);
        break;
      case CompanyRole.member:
        writer.writeByte(2);
        break;
      case CompanyRole.guest:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
