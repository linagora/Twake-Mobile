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
    // ignore same terms
    if (newTerm == state.searchTerm) {
      return;
    }

    emit(state.copyWith(searchTerm: newTerm));

    fetchChatsBySearchTerm();
    fetchMessagesBySearchTerm();
    fetchFilesBySearchTerm();
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

  void fetchInitialResults() {
    fetchRecentChats();
    fetchChatsBySearchTerm();
    fetchFilesBySearchTerm();
  }

  void fetchRecentChats() async {
    emit(state.copyWith(chatsStateStatus: ChatsStateStatus.loading));

    final request = await _searchRepository.fetchRecentChats();

    if (request.hasError) {
      emit(state.copyWith(chatsStateStatus: ChatsStateStatus.failed));
      return;
    }

    emit(state.copyWith(
        chatsStateStatus: ChatsStateStatus.done, recentChats: request.result));
  }

  void fetchChatsBySearchTerm() async {
    emit(state.copyWith(chatsStateStatus: ChatsStateStatus.loading));

    final request =
        await _searchRepository.fetchChats(searchTerm: state.searchTerm);

    if (request.hasError) {
      emit(state.copyWith(chatsStateStatus: ChatsStateStatus.failed));
      return;
    }

    final requestUsers =
        await _searchRepository.fetchUsers(searchTerm: state.searchTerm);

    if (requestUsers.hasError) {
      emit(state.copyWith(chatsStateStatus: ChatsStateStatus.failed));
      return;
    }

    emit(state.copyWith(
        chatsStateStatus: ChatsStateStatus.done,
        chats: request.result,
        users: requestUsers.result));
  }

  void fetchMessagesBySearchTerm() async {
    emit(state.copyWith(messagesStateStatus: MessagesStateStatus.loading));

    final request =
        await _searchRepository.fetchMessages(searchTerm: state.searchTerm);

    if (request.hasError) {
      emit(state.copyWith(messagesStateStatus: MessagesStateStatus.failed));
      return;
    }

    emit(state.copyWith(
      messagesStateStatus: MessagesStateStatus.done,
      messages: request.result,
    ));
  }

  void fetchFilesBySearchTerm() async {
    emit(state.copyWith(filesStateStatus: FilesStateStatus.loading));

    final request =
        await _searchRepository.fetchFiles(searchTerm: state.searchTerm);

    if (request.hasError) {
      emit(state.copyWith(filesStateStatus: FilesStateStatus.failed));
      return;
    }

    emit(state.copyWith(
        filesStateStatus: FilesStateStatus.done, files: request.result));
  }

  void setTextEditingController(TextEditingController controller) {
    _textEditingController = controller;
  }

  void resetSearch() {
    onSearchTermChanged('');
    _textEditingController?.text = '';
  }
}
