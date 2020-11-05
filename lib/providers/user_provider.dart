import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/user.dart';

class CompaniesProvider with ChangeNotifier {
  User _currentUser;

  User get currentUser => _currentUser;

  Future<void> loadUser(Map<String, dynamic> json) async {
    _currentUser = User.fromJson(json);
  }
}
