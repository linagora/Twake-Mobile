import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/company.dart';

class CompaniesProvider with ChangeNotifier {
  List<Company> _items = [];

  List<Company> get items => _items;

  int get itemCount {
    return _items.length;
  }

  void loadCompanies(List<Map<String, dynamic>> jsonList) {
    jsonList.forEach((c) => _items.add(Company.fromJson(c)));
    notifyListeners();
  }

  Company getById(String id) {
    return _items.firstWhere((c) => c.id == id);
  }
}
