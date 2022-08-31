import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'context.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Context extends Equatable {
  @JsonKey(name: 'target_type')
  final String targetType;
  @JsonKey(name: 'company_id')
  final String companyId;
  @JsonKey(name: 'target_id')
  final String targetId;
  final String id;
  @JsonKey(name: 'channel_id')
  final String channelId;
  @JsonKey(name: 'file_id')
  final String fileId;
  @JsonKey(name: 'message_file_id')
  final String messageFileId;
  @JsonKey(name: 'message_id')
  final String messageId;
  @JsonKey(name: 'thread_id')
  final String threadId;
  @JsonKey(name: 'workspace_id')
  final String workspaceId;

  Context(
      {required this.targetType,
      required this.targetId,
      required this.channelId,
      required this.companyId,
      required this.fileId,
      required this.id,
      required this.messageFileId,
      required this.messageId,
      required this.threadId,
      required this.workspaceId});

  factory Context.fromJson(Map<String, dynamic> json) {
    return _$ContextFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ContextToJson(this);

  @override
  List<Object?> get props => [
        targetType,
        targetId,
        channelId,
        companyId,
        fileId,
        id,
        messageFileId,
        messageId,
        threadId,
        workspaceId
      ];
}
