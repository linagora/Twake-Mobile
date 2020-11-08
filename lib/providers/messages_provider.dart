import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/services/twake_api.dart';

// BIG TODO. May be, I should consider implementing all those Provider classes
// via some generic class. May be...

class MessagesProvider extends ChangeNotifier {
  List<Message> _items = List();
  bool loaded = false;
  MessagesProvider() {
    print('MessagesProvider is instantiated');
  }

  List<Message> get items => [..._items];

  int get messagesCount => _items.length;

  Future<void> loadMessages(TwakeApi api, String channelId) async {
    print('loadMessages is called');
    var list;
    try {
      list = await api.channelMessagesGet(channelId);
    } catch (error) {
      // TODO implement proper error handling
      print('ERROR WHILE LOADING MESSAGES:\n$error');
      throw error;
    }
    _items.clear();
    print('items cleared:\n${list.length}');
    for (var i = 0; i < list.length; i++) {
      print('Adding item $i:\n${list[i]}');
      _items.add(Message.fromJson(list[i]));
      print('Items:\n$_items');
    }
    loaded = true;
    print('Notifying listeners with items:\n$_items');
    notifyListeners();
  }
}
