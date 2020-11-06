import 'package:flutter/foundation.dart';
// Import this to use local dummy data
// import 'package:twake_mobile/data/dummy.dart';
import 'package:twake_mobile/services/twake_api.dart';

class InitProvider with ChangeNotifier {
  Map<String, dynamic> _initData = Map();

  Future<void> init(TwakeApi api) async {
    try {
      _initData = await api.currentUserGet();
      notifyListeners();
    } on FormatException catch (fe) {
      print(fe);
    } catch (error) {
      print('ERROR ON INIT PROVIDER');
      print(error);
    }
  }

  Map<String, dynamic> get userData => _initData;
  List get companies {
    return _initData['companies'];
  }

  List<dynamic> companyWorkspaces(String id) {
    return (_initData['companies'])
        .firstWhere((c) => c['id'] == id)['workspaces'];
    // whoa, that's pretty ugly peice of the code
    // TODO figure out how to avoid working on dynamic map, and use more
    // statically typed solution
  }
}
