// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

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
