import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/services/twake_api.dart';

class ChannelsProvider with ChangeNotifier {
  List<Channel> _items = List();
  bool loaded = false;

  List<Channel> get items => [..._items];

  int get channelCount => _items.length;

  Future<void> loadChannels(TwakeApi api, String workspaceId) async {
    var list;
    try {
      list = await api.workspaceChannelsGet(workspaceId);
    } catch (error) {
      print('Error occured while loading channels\n$error');
      throw error;
    }
    _items.clear();
    for (var i = 0; i < list.length; i++) {
      _items.add(Channel.fromJson(list[i]));
    }
    loaded = true;
    notifyListeners();
  }
}
