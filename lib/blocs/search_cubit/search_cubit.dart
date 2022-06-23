import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/repositories/contacts_repository.dart';
import 'package:twake/repositories/search_repository.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _searchRepository;
  final ContactsRepository _contactsRepository;

  TextEditingController? _textEditingController;

  SearchCubit(this._searchRepository, this._contactsRepository)
      : super(SearchState.initial());

  factory SearchCubit.initWithRepository() {
    return SearchCubit(SearchRepository(), ContactsRepository());
  }

  void onSearchTermChanged(String newTerm) {
    emit(state.copyWith(searchTerm: newTerm));

    fetchUsersBySearchTerm();
  }

  void getAllContacts() async {
    emit(state.copyWith(contactsStateStatus: ContactsStateStatus.loading));

    final result = await _contactsRepository.fetchAllContacts();

    if (!result.hasPermissions) {
      emit(state.copyWith(
          contactsStateStatus: ContactsStateStatus.noPermission));
      return;
    }

    if (result.hasError) {
      emit(state.copyWith(contactsStateStatus: ContactsStateStatus.failed));
      return;
    }

    emit(state.copyWith(
        contactsStateStatus: ContactsStateStatus.done,
        contacts: result.contacts));
  }

  void fetchUsersBySearchTerm() async {
    emit(state.copyWith(contactsStateStatus: ContactsStateStatus.loading));

    final result =
        await _searchRepository.fetchUsers(searchTerm: state.searchTerm);

    if (result.hasError) {
      emit(state.copyWith(contactsStateStatus: ContactsStateStatus.failed));
      return;
    }

    emit(state.copyWith(
        contactsStateStatus: ContactsStateStatus.done, users: result.users));
  }

  void setTextEditingController(TextEditingController controller) {
    _textEditingController = controller;
  }

  void resetSearch() {
    onSearchTermChanged('');
    _textEditingController?.text = '';
  }
}
