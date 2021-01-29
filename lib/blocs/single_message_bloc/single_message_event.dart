import 'package:equatable/equatable.dart';

abstract class SingleMessageEvent extends Equatable {
  const SingleMessageEvent();
}

class UpdateContent extends SingleMessageEvent {
  final String content;

  const UpdateContent(this.content);

  @override
  List<Object> get props => [content];
}

class UpdateReaction extends SingleMessageEvent {
  final String emojiCode;
  final String userId;
  final String companyId;
  final String workspaceId;

  const UpdateReaction({
    this.emojiCode,
    this.userId,
    this.companyId,
    this.workspaceId,
  });

  @override
  List<Object> get props => [emojiCode, userId];
}

class UpdateResponseCount extends SingleMessageEvent {
  final int modifier;

  UpdateResponseCount(this.modifier) : assert(modifier.abs() == 1);

  @override
  List<Object> get props => [modifier];
}

class UpdateViewport extends SingleMessageEvent {
  final double position;

  UpdateViewport(this.position);

  @override
  List<Object> get props => [position];
}
