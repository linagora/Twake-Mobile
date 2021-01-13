part of '../blocs/sheet_bloc.dart';

abstract class SheetEvent extends Equatable {
  const SheetEvent();
}

class InitSheet extends SheetEvent {
  const InitSheet();

  @override
  List<Object> get props => [];
}

class OpenSheet extends SheetEvent {
  const OpenSheet();

  @override
  List<Object> get props => [];
}

class CloseSheet extends SheetEvent {
  const CloseSheet();

  @override
  List<Object> get props => [];
}

class CacheSheet extends SheetEvent {
  const CacheSheet();

  @override
  List<Object> get props => [];
}

class ClearSheet extends SheetEvent {
  const ClearSheet();

  @override
  List<Object> get props => [];
}

class ProcessSheet extends SheetEvent {
  const ProcessSheet();

  @override
  List<Object> get props => [];
}