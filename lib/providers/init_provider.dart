// import 'dart:convert' as convert;

import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
import 'package:twake_mobile/data/dummy.dart';

class InitProvider with ChangeNotifier {
  Map<String, dynamic> _initData = Map();

  Future<void> init() async {
    try {
      // var response = await http.get('https://tools.ietf.org/html/rfc1');
      // print(response.body);
      // _initData = convert.jsonDecode(response.body);
      _initData = DUMMY;
      notifyListeners();
    } on FormatException catch (fe) {
      print(fe);
    } catch (error) {
      print(error);
    }
  }

  Map<String, dynamic> get userData => _initData;
  List<Map<String, dynamic>> get companies => _initData['companies'];
  List<Map<String, dynamic>> companyWorkspaces(String id) {
    return (_initData['companies'] as List<Map<String, dynamic>>)
        .firstWhere((c) => c['id'] == id)['workspaces'];
    // whoa, that's pretty ugly peice of the code
    // TODO figure out how to avoid working on dynamic map, and use more
    // statically typed solution
  }
}
