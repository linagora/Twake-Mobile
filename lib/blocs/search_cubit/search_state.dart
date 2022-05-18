import 'package:equatable/equatable.dart';

abstract class SearchState extends Equatable {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();

  @override
  List<Object?> get props => [];
}
