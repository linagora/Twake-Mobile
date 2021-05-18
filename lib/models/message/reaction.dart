import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Reaction {
  final String name;
  final List<String> users;
  final int count;

  const Reaction({
    required this.name,
    required this.users,
    required this.count,
  });
}
