import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/models/direct.dart';
import 'package:twake_mobile/services/db.dart';
import 'package:twake_mobile/services/twake_api.dart';

class ChannelsProvider with ChangeNotifier {
  List<Channel> _items = List();
  List<Direct> _directs = List();
  bool loaded = false;

  List<Channel> get items => [..._items];
  List<Direct> get directs => [..._directs];

  int get channelCount => _items.length;
  int get directsCount => _directs.length;

  Channel getChannelById(String channelId) =>
      _items.firstWhere((c) => c.id == channelId);

  Direct getDirectsById(String directId) =>
      _directs.firstWhere((d) => d.id == directId);

  // cannot sort for now, because lastActivity is not updated
  void directsSort() {
    _directs.sort((d1, d2) => d2.lastActivity.compareTo(d1.lastActivity));
    notifyListeners();
  }

  Future<void> loadChannels(TwakeApi api, String workspaceId,
      {String companyId}) async {
    loaded = false;
    var list;
    try {
      /// try to get channels from api
      list = await api.workspaceChannelsGet(workspaceId);
      print('LOADED channels over NETWORK');
    } catch (error) {
      /// if we fail (network issue), then load channels from local store
      list = await DB.channelsLoad(workspaceId);
      print('LOADED channels from STORE');
    } finally {
      _items.clear();
      for (var i = 0; i < list.length; i++) {
        _items.add(Channel.fromJson(list[i], workspaceId));
      }
      _items.sort((a, b) => a.name.compareTo(b.name));
    }
    var directs;

    /// Reload direct messages only if current company has changed
    if (companyId != null) {
      try {
        directs = await api.directMessagesGet(companyId);
      } catch (error) {
        print('Error occured when loading directs\n$error');
      } finally {
        _directs.clear();
        for (var i = 0; i < directs.length; i++) {
          _directs.add(Direct.fromJson(directs[i]));
        }
        _directs.sort((d1, d2) => d2.lastActivity.compareTo(d1.lastActivity));
      }
    }
    loaded = true;
    DB.channelsSave(_items);
    notifyListeners();
  }
}
