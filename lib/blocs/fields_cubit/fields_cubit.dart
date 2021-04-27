import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:twake/repositories/fields_repository.dart';
import 'fields_state.dart';

class FieldsCubit extends Cubit<FieldsState> {
  final FieldsRepository repository;

  FieldsCubit(this.repository) : super(FieldsInitial());

  Future<void> add({@required Widget field, @required int atIndex}) async {
    final result = await repository.add(field, atIndex);
    // print('Current map: ${repository.data}');
    emit(Added(fields: result));
  }

  Future<void> remove({@required int atIndex}) async {
    final result = await repository.remove(atIndex);
    // print('Current map: ${repository.data}');
    emit(Removed(fields: result));
  }

  Future<void> update({
    @required String withContent,
    @required int atIndex,
  }) async {
    final result = await repository.updateData(atIndex, withContent);
    // print('Current map: $result');
    emit(Updated(data: result));
  }

  Future<void> clear() async {
    final result = await repository.clear();
    emit(
      result.isEmpty
          ? Cleared()
          : Error('Something went wrong on fields clearing.'),
    );
  }

  List<Widget> getAll() => repository.getAll();
}
