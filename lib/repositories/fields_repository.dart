import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class FieldsRepository {
  List<Widget> fields;

  FieldsRepository({@required this.fields});

  Future<List<Widget>> clear() async {
    fields = [];
    return List<Widget>.from(fields);
  }

  Future<List<Widget>> add(Widget field) async {
    fields.add(field);
    return List<Widget>.from(fields);
  }

  Future<List<Widget>> remove(int index) async {
    fields.removeAt(index);
    return List<Widget>.from(fields);
  }
}
