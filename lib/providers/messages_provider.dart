import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/services/twake_api.dart';

// BIG TODO. May be, I should consider implementing all those Provider classes
// via some generic class. May be...

class MessagesProvider extends ChangeNotifier {
  final logger = Logger();
  List<Message> _items = List();
  bool loaded = false;
  bool _fetchInProgress = false; // Marker for loadMoreMessages
  bool _topHit = false;
  String channelId;
  TwakeApi api;

  List<Message> get items => [..._items];

  int get messagesCount => _items.length;

  String get firstMessageId => _items[0].id;

  Message getMessageById(String messageId) {
    return _items.firstWhere((m) => m.id == messageId, orElse: () => null);
  }

  void clearMessages() {
    _items.clear();
    loaded = false;
  }

  void addMessage(Map<String, dynamic> message, {String threadId}) {
    var _message = Message.fromJson(message)..channelId = channelId;
    if (threadId != null) {
      var message = _items.firstWhere((m) => m.id == threadId);
      if (message.responses == null) {
        message.responses = [];
      }
      _message.threadId = threadId;
      message.responses.add(_message);
      message.responsesCount = (message.responsesCount ?? 0) + 1;
    } else {
      _items.add(_message);
    }
    notifyListeners();
  }

  Future<void> removeMessage(String messageId, {String threadId}) async {
    await api.messageDelete(
      channelId,
      messageId,
      threadId: threadId,
    );
    if (threadId != null && threadId.isNotEmpty) {
      var message = getMessageById(threadId);
      message.responsesCount--;
      message.responses.removeWhere((m) => m.id == messageId);
    } else {
      _items.firstWhere((m) => m.id == messageId)..hidden = true;
    }
    notifyListeners();
  }

  Future<void> loadMessages(TwakeApi api, String channelId) async {
    _topHit = false;
    var list;
    this.api = api;
    this.channelId = channelId;
    try {
      list = await api.channelMessagesGet(channelId);
    } catch (error) {
      logger.e('Error while loading messages\n$error');
      // TODO implement proper error handling
      throw error;
    }
    for (var i = 0; i < list.length; i++) {
      _items.add(Message.fromJson(list[i])..channelId = channelId);
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> loadMoreMessages() async {
    if (_topHit) return;
    if (_fetchInProgress) return;
    _fetchInProgress = true;
    var list;
    logger.d('Trying to load first message id\n$channelId\n$firstMessageId');
    try {
      list = await api.channelMessagesGet(
        channelId,
        beforeMessageId: firstMessageId,
      );
    } catch (error) {
      // TODO implement proper error handling
      throw error;
    }
    // This checks are neccessary because of how often
    // Notifications on scroll's end might fire, and trigger
    // refetch of data which is already present
    if (list[list.length - 1]['id'] == firstMessageId) {
      list.removeLast();
    }
    if (list.isEmpty) {
      // if (list.length < 1) {
      logger.e('NO MORE MESSAGES LEFT!');
      _topHit = true;
      return;
    }
    List<Message> tmp = List();
    for (var i = 0; i < list.length; i++) {
      tmp.add(Message.fromJson(list[i]));
    }
    _items = tmp + _items;
    _fetchInProgress = false;
    notifyListeners();
  }

  Future<void> getMessageOnUpdate({
    String channelId,
    String messageId,
    String threadId,
  }) async {
    logger.d('Updating messages on notify!');
    if (channelId == this.channelId) {
      final list = await api.channelMessagesGet(
        channelId,
        messageId: messageId,
        threadId: threadId,
      );
      // if list returned is empty, then message has been deleted
      if (list.isEmpty) {
        // if threadId was present, remove response
        if (threadId != null) {
          var message = getMessageById(threadId);
          message.responsesCount--;
          message.responses.removeWhere((m) => m.id == messageId);
        } else {
          // else remove the message itself
          _items.removeWhere((m) => m.id == messageId);
        }
        notifyListeners();
        return;
      }
      var newMessage = Message.fromJson(list[0]);
      // Add message to channel
      if (threadId == null) {
        var message = getMessageById(messageId);
        // if message exists already, update it
        if (message != null) {
          logger.d('message is found');
          message.doPartialUpdate(newMessage);
          logger.d('message has been updated');
          message.notifyListeners();
          notifyListeners();
        } else {
          // else add a new one
          logger.d('message not found');
          _items.add(newMessage);
        }
      } else {
        // Add message to thread
        logger.d('Addeing message to the thread');
        var message = getMessageById(threadId);
        var response = message.responses
            .firstWhere((r) => r.id == messageId, orElse: () => null);
        // if message doesn't exists, add new to the thread
        if (response == null) {
          message.responsesCount++;
          message.responses.add(newMessage);
        } else {
          // else just update existing one
          response.doPartialUpdate(newMessage);
        }
      }
      notifyListeners();
    }
  }
}
