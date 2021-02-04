import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:twake/repositories/fields_repository.dart';
import 'fields_state.dart';

class FieldsCubit extends Cubit<FieldsState> {
  final FieldsRepository repository;

  FieldsCubit(this.repository) : super(FieldsInitial());

  void add(Widget field) async {
    final result = await repository.add(field);
    emit(Added(fields: result));
  }

  void remove(int index) async {
    final result = await repository.remove(index);
    emit(Removed(fields: result));
  }

  void clear() async {
    final result = await repository.clear();
    emit(
      result.isEmpty
          ? Cleared()
          : Error('Something went wrong on fields clearing.'),
    );
  }
}
