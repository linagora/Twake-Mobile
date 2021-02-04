import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class FieldsRepository {
  List<Widget> fields;

  FieldsRepository({@required this.fields});

  Future<List<Widget>> clear() async {
    fields = [];
    return fields;
  }

  Future<List<Widget>> add(Widget field) async {
    fields.add(field);
    return fields;
  }

  Future<List<Widget>> remove(int index) async {
    fields.removeAt(index);
    return fields;
  }
}
