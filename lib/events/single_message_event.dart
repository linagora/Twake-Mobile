import 'package:equatable/equatable.dart';
import 'package:twake/models/twacode.dart';

abstract class SingleMessageEvent extends Equatable {
  const SingleMessageEvent();
}

class UpdateContent extends SingleMessageEvent {
  final MessageTwacode content;
  const UpdateContent(this.content);

  @override
  List<Object> get props => [content];
}

class UpdateReaction extends SingleMessageEvent {
  final String emojiCode;
  final String userId;

  const UpdateReaction({this.emojiCode, this.userId});

  @override
  List<Object> get props => [emojiCode, userId];
}

class UpdateResponseCount extends SingleMessageEvent {
  final int modifier;

  UpdateResponseCount(this.modifier) : assert(modifier.abs() == 1);

  @override
  List<Object> get props => [modifier];
}
