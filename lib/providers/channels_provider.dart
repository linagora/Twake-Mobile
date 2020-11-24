import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/services/db.dart';
import 'package:twake_mobile/services/twake_api.dart';

class ChannelsProvider with ChangeNotifier {
  List<Channel> _items = List();
  bool loaded = false;

  List<Channel> get items => [..._items];

  int get channelCount => _items.length;

  Channel getById(String channelId) =>
      _items.firstWhere((c) => c.id == channelId);

  Future<void> loadChannels(TwakeApi api, String workspaceId) async {
    loaded = false;
    var list;
    try {
      /// try to get channels from api
      list = await api.workspaceChannelsGet(workspaceId);
    } catch (error) {
      /// if we fail (network issue), then load channels from local store
      list = await DB.channelsLoad(workspaceId);
    } finally {
      _items.clear();
      for (var i = 0; i < list.length; i++) {
        _items.add(Channel.fromJson(list[i], workspaceId));
      }
      _items.sort((a, b) => a.name.compareTo(b.name));
      loaded = true;
      DB.channelsSave(_items);
      notifyListeners();
    }
  }
}
