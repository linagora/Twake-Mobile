import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User extends Equatable {
  final String id;
  final String email;
  final String? userName;
  final String? firstName;
  final String? lastName;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? picture;
  final String? providerId;
  final String? status;
  final int lastActivity;
  @JsonKey(name: 'last_seen')
  final int? lastSeen;
  @JsonKey(name: 'is_connected')
  final bool? isConnected;
  @JsonKey(name: 'is_verified')
  final bool verified;
  final bool deleted;

  User({
    required this.id,
    required this.email,
    this.userName,
    this.firstName,
    this.lastName,
    this.lastSeen,
    this.isConnected,
    required this.fullName,
    required this.verified,
    required this.deleted,
    this.picture,
    this.providerId,
    this.status,
    required this.lastActivity,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        fullName,
        verified,
        deleted,
        picture,
        status,
        lastActivity,
        lastSeen,
        lastSeen
      ];
}
