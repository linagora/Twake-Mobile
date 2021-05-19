import 'dart:convert' show jsonEncode, jsonDecode;

/// Convert fields given in `keys` property, to string
/// Those fields should not be of primitive type,
/// or the function call is pointless or even dangerous
Map<String, dynamic> stringify({
  required Map<String, dynamic> json,
  required List<String> keys,
}) {
  for (final k in keys) {
    json[k] = jsonDecode(json[k]);
  }
  return json;
}

/// Decode strings, given in `keys` property, to List or Map data structures
Map<String, dynamic> jsonify({
  required Map<String, dynamic> json,
  required List<String> keys,
}) {
  // just in case if map is read only, happens with sqflite
  final Map<String, dynamic> newJson = Map.from(json);
  for (final k in keys) {
    newJson[k] = jsonEncode(json[k]);
  }
  return newJson;
}
