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

  Future<void> loadMessages(
    TwakeApi api,
    String channelId, {
    String threadId,
  }) async {
    Message message;
    if (threadId != null) {
      message = getMessageById(threadId);
      if (message.responsesLoaded) {
        return;
      }
    }
    while (_fetchInProgress) {
      await Future.delayed(Duration(milliseconds: 200));
    }

    // Just make sure that we don't have messages before fetching
    if (_items.isNotEmpty && threadId == null) _items.clear();
    _fetchInProgress = true;
    _topHit = false;
    var list;
    this.api = api;
    this.channelId = channelId;
    try {
      list = await api.channelMessagesGet(channelId, threadId: threadId);
    } catch (error) {
      logger.e('Error while loading messages\n$error');
      // TODO implement proper error handling
      throw error;
    } finally {
      _fetchInProgress = false;
    }
    if (threadId != null) {
      message.responses = [];
      for (var i = 0; i < list.length; i++) {
        message.responses.add(Message.fromJson(list[i])..channelId = channelId);
        logger.d('RESPONSES COUNT ${message.responses.length}');
      }
      message.responsesLoaded = true;
    } else {
      for (var i = 0; i < list.length; i++) {
        // try {
        _items.add(Message.fromJson(list[i])..channelId = channelId);
        // } catch (error) {
        //   logger.e('Error while parsing message\n$error');
        //   logger.e('MESSAGE WAS\n${list[i]}');
        //   // TODO implement proper error handling
        //   continue;
        // }
      }
    }
    // logger.d('GOT ${_items.length} message in provider');
    loaded = true;
    _fetchInProgress = false;
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
    } finally {
      _fetchInProgress = false;
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
    logger.d('Current ChannelID: ${this.channelId}');
    logger.d('Requested ChannelID: $channelId');
    logger.d('Is current channel: ${this.channelId == channelId}');
    if (channelId == this.channelId) {
      final list = await api.channelMessagesGet(
        channelId,
        messageId: messageId,
        threadId: threadId,
      );
      logger.d('Received message for notify from api');
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
        logger.d('Message was deleted');
        notifyListeners();
        return;
      }
      logger.d('Parsing message from json');
      var newMessage = Message.fromJson(list[0]);
      // Add message to channel
      if (threadId == null) {
        logger.d('Adding message to channel');
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
          message.responsesCount = (message.responsesCount ?? 0) + 1;
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
