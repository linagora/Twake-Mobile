import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/workspace.dart';

class WorkspacesProvider with ChangeNotifier {
  List<Workspace> _items = List();

  List<Workspace> get items => [..._items];

  void loadWorkspaces(List<dynamic> list) {
    if (list == null) return;
    for (var i = 0; i < list.length; ++i) {
      final map = {
        'id': list[i]['id'],
        'name': list[i]['name'],
        'logo': list[i]['logo'],
      };
      _items.add(Workspace.fromJson(map));
    }
    notifyListeners();
  }
}
