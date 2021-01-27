import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/message_edit_event.dart';
import 'package:twake/states/message_edit_state.dart';

export 'package:twake/events/message_edit_event.dart';
export 'package:twake/states/message_edit_state.dart';

class MessageEditBloc extends Bloc<MessageEditEvent, MessageEditState> {
  MessageEditBloc() : super(NoMessageToEdit());

  @override
  Stream<MessageEditState> mapEventToState(MessageEditEvent event) async* {
    if (event is EditMessage) {
      yield MessageEditing(
        onMessageEditComplete: event.onMessageEditComplete,
        originalStr: event.originalStr,
      );
    } else if (event is CancelMessageEdit) {
      yield NoMessageToEdit();
    }
  }
}
