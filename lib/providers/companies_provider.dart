import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/company.dart';

class CompaniesProvider with ChangeNotifier {
  List<Company> _items = [];

  List<Company> get items => [..._items];

  int get itemCount {
    return _items.length;
  }

  void loadCompanies(List<dynamic> jsonList) {
    if (jsonList == null) return;
    if (jsonList.isEmpty) return;

    _items.clear();
    for (var i = 0; i < jsonList.length; ++i) {
      final map = {
        'id': jsonList[i]['id'],
        'name': jsonList[i]['name'],
        'logo': jsonList[i]['logo'],
      };

      _items.add(Company.fromJson(map));
    }
    notifyListeners();
  }

  Company getById(String id) {
    return _items.firstWhere((c) => c.id == id);
  }
}
