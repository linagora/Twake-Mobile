import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/services/twake_api.dart';

// BIG TODO. May be, I should consider implementing all those Provider classes
// via some generic class. May be...

class MessagesProvider extends ChangeNotifier {
  List<Message> _items = List();
  bool loaded = false;
  String _channelId;
  TwakeApi api;

  List<Message> get items => [..._items];

  int get messagesCount => _items.length;

  String get firstMessageId => _items[0].id;

  void clearMessages() {
    _items.clear();
    loaded = false;
  }

  Future<void> loadMessages(TwakeApi api, String channelId) async {
    clearMessages();
    var list;
    this.api = api;
    this._channelId = channelId;
    try {
      list = await api.channelMessagesGet(channelId);
    } catch (error) {
      // TODO implement proper error handling
      throw error;
    }
    for (var i = 0; i < list.length; i++) {
      _items.add(Message.fromJson(list[i]));
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> loadMoreMessages() async {
    var list;
    // List<Message> tmp = List();
    try {
      list = await api.channelMessagesGet(
        _channelId,
        beforeMessageId: firstMessageId,
      );
    } catch (error) {
      // TODO implement proper error handling
      throw error;
    }
    // This is checks are neccessary because of how often
    // Notifications on scroll end might fire, and trigger
    // refetch of data which is already present
    if (list.length < 2 || list[0]['id'] == firstMessageId) {
      return;
    }
    List<Message> tmp = List();
    for (var i = 0; i < list.length; i++) {
      tmp.add(Message.fromJson(list[i]));
    }
    _items = tmp + _items;
    loaded = true;
    notifyListeners();
  }
}
