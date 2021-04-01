import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class FieldsState extends Equatable {
  List<Widget> get fields;

  const FieldsState();
}

class FieldsInitial extends FieldsState {
  @override
  List<Object> get props => [];

  @override
  List<Widget> get fields => [];
}

class Added extends FieldsState {
  final List<Widget> fields;

  Added({@required this.fields});

  @override
  List<Object> get props => [fields];
}

class Removed extends FieldsState {
  final List<Widget> fields;

  Removed({@required this.fields});

  @override
  List<Object> get props => [fields];
}

class Cleared extends FieldsState {
  @override
  List<Object> get props => [];

  @override
  List<Widget> get fields => [];
}

class Updated extends FieldsState {
  final Map<int, String> data;

  Updated({@required this.data});

  @override
  List<Object> get props => [data];

  @override
  List<Widget> get fields => [];
}

class Error extends FieldsState {
  final String message;

  Error(this.message);

  @override
  List<Object> get props => [message];

  @override
  List<Widget> get fields => [];
}
