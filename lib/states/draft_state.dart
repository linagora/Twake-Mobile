part of '../blocs/draft_bloc.dart';

abstract class DraftState extends Equatable {
  const DraftState();
}

class DraftInitial extends DraftState {
  @override
  List<Object> get props => [];
}
