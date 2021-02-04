import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

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
    fields.removeAt(index);
    data.remove(index);
    return List<Widget>.from(fields);
  }

  Future<Map<int, String>> updateData(int index, String content) async {
    data[index] = content;
    return Map<int, String>.from(data);
  }
}
