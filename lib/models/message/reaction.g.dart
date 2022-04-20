// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReactionAdapter extends TypeAdapter<Reaction> {
  @override
  final int typeId = 21;

  @override
  Reaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reaction(
      name: fields[0] as String,
      users: (fields[1] as List).cast<String>(),
      count: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Reaction obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.users)
      ..writeByte(2)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reaction _$ReactionFromJson(Map<String, dynamic> json) {
  return Reaction(
    name: json['name'] as String,
    users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
    count: json['count'] as int,
  );
}

Map<String, dynamic> _$ReactionToJson(Reaction instance) => <String, dynamic>{
      'name': instance.name,
      'users': instance.users,
      'count': instance.count,
    };
