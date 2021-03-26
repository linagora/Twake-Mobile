import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:twake/widgets/sheets/add/collaborators_list.dart';
import 'package:twake/widgets/sheets/removable_text_field.dart';

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
        // print('key: $key');
        // print('newIndex: $newIndex');
        final field = RemovableTextField(
          key: UniqueKey(),
          index: newIndex,
          isLastOne: data.length > 1 ? newIndex == data.length - 2 : true,
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
    print('Content: $content');
    print('Index: $index');

    data[index] = content;
    print('Data: $data');

    return Map<int, String>.from(data);
  }
}
