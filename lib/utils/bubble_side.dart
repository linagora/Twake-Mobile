import 'package:twake/models/message/message.dart';
import 'dateformatter.dart';

List<bool> bubbleSide(List<Message> messages, int index, bool isNotThread) {
  final List<bool> bubbleSide = List<bool>.filled(2, false, growable: false);
  bool upBubbleSide = false;
  bool downBubbleSide = false;
  //conditions for determining the shape of the bubble sides
  //if there is only one message in the chat
  if (messages.length == 1) {
    upBubbleSide = true;
    downBubbleSide = true;
  } else {
    // boundary bubbles handling
    if (index == 0 || index == messages.length - 1) {
      if (index == 0) {
        if (messages[messages.length - index - 1].userId !=
            messages[messages.length - index - 1 - 1].userId) {
          upBubbleSide = true;
        } else {
          upBubbleSide = false;
        }
        downBubbleSide = true;
        //Conditions for accounting for the change of day
        if (isNotThread &&
            DateFormatter.getVerboseDate(
                    messages[messages.length - index - 1].createdAt) !=
                DateFormatter.getVerboseDate(
                    messages[messages.length - index - 1 - 1].createdAt)) {
          upBubbleSide = true;
        }
      }
      if (index == messages.length - 1) {
        if (messages[messages.length - index - 1].userId !=
            messages[messages.length - index - 1 + 1].userId) {
          downBubbleSide = true;
        } else {
          downBubbleSide = false;
        }
        upBubbleSide = true;
        //Conditions for accounting for the change of day
        if (isNotThread &&
            DateFormatter.getVerboseDate(
                    messages[messages.length - index - 1].createdAt) !=
                DateFormatter.getVerboseDate(
                    messages[messages.length - index - 1 + 1].createdAt)) {
          downBubbleSide = true;
        }
      }
    } else {
      // processing of all basic bubbles in the chat except of boundary values
      if (messages[messages.length - index - 1].userId !=
          messages[messages.length - index - 1 + 1].userId) {
        downBubbleSide = true;
      } else {
        downBubbleSide = false;
      }
      if (messages[messages.length - index - 1].userId !=
          messages[messages.length - index - 1 - 1].userId) {
        upBubbleSide = true;
      } else {
        upBubbleSide = false;
      }
      //Conditions for accounting for the change of day
      if (isNotThread &&
          DateFormatter.getVerboseDate(
                  messages[messages.length - index - 1].createdAt) !=
              DateFormatter.getVerboseDate(
                  messages[messages.length - index - 1 + 1].createdAt)) {
        downBubbleSide = true;
      }
      if (isNotThread &&
          DateFormatter.getVerboseDate(
                  messages[messages.length - index - 1].createdAt) !=
              DateFormatter.getVerboseDate(
                  messages[messages.length - index - 1 - 1].createdAt)) {
        upBubbleSide = true;
      }
    }
  }
  bubbleSide[0] = upBubbleSide;
  bubbleSide[1] = downBubbleSide;
  return bubbleSide;
}
