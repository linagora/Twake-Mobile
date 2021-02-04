import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:twake/widgets/sheets/collaborators_list.dart';

class FieldsRepository {
  List<Widget> fields;
  Map<int, String> data;

  FieldsRepository({
    @required this.fields,
    @required this.data,
  });

  Future<List<Widget>> clear() async {
    fields = [];
    data = {};
    return List<Widget>.from(fields);
  }

  Future<List<Widget>> add(Widget field, int index) async {
    fields.add(field);
    data[index] = '';
    return List<Widget>.from(fields);
  }

  Future<List<Widget>> remove(int index) async {
    var newIndex = 0;
    var newFields = <Widget>[];
    var newMap = <int, String>{};

    for (var key in data.keys) {
      if (key != index) {
        final content = data[key];
        final field = RemovableTextField(
          index: newIndex,
          isLastOne: newIndex == fields.length - 2,
          initialText: content,
        );
        newFields.add(field);
        newMap[newIndex] = content;
        newIndex++;
      }
    }
    data = newMap;
    fields = newFields;
    return fields;
  }

  Future<Map<int, String>> updateData(int index, String content) async {
    data[index] = content;
    return Map<int, String>.from(data);
  }
}
