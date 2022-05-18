import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/repositories/search_repository.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _searchRepository;

  SearchCubit(final this._searchRepository) : super(SearchInitial());
}
