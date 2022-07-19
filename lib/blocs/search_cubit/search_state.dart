import 'package:equatable/equatable.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/models/contacts/app_contact.dart';
import 'package:twake/repositories/search_repository.dart';

enum ContactsStateStatus { init, loading, done, failed, noPermission }
enum ChatsStateStatus { init, loading, done, failed }
enum MessagesStateStatus { init, loading, done, failed }

class SearchState extends Equatable {
  final String searchTerm;

  // different state will help run queries in concurrent mode
  final ContactsStateStatus contactsStateStatus;
  final ChatsStateStatus chatsStateStatus;
  final MessagesStateStatus messagesStateStatus;

  final List<AppContact> contacts;
  final List<Account> users;
  final List<Channel> recentChats;
  final List<Channel> chats;
  final List<SearchMessage> messages;

  const SearchState(
      {required this.searchTerm,
      required this.users,
      required this.recentChats,
      required this.contactsStateStatus,
      required this.chatsStateStatus,
      required this.messagesStateStatus,
      required this.chats,
      required this.messages,
      required this.contacts});

  factory SearchState.initial() {
    return SearchState(
        searchTerm: '',
        contactsStateStatus: ContactsStateStatus.init,
        users: [],
        chats: [],
        messages: [],
        recentChats: [],
        chatsStateStatus: ChatsStateStatus.init,
        messagesStateStatus: MessagesStateStatus.init,
        contacts: []);
  }

  SearchState copyWith({
    final String? searchTerm,
    final ContactsStateStatus? contactsStateStatus,
    final List<AppContact>? contacts,
    final List<Account>? users,
    final List<Channel>? recentChats,
    final List<Channel>? chats,
    final List<SearchMessage>? messages,
    final ChatsStateStatus? chatsStateStatus,
    final MessagesStateStatus? messagesStateStatus,
  }) {
    return SearchState(
      searchTerm: searchTerm ?? this.searchTerm,
      contactsStateStatus: contactsStateStatus ?? this.contactsStateStatus,
      contacts: contacts ?? this.contacts,
      users: users ?? this.users,
      recentChats: recentChats ?? this.recentChats,
      chats: chats ?? this.chats,
      chatsStateStatus: chatsStateStatus ?? this.chatsStateStatus,
      messagesStateStatus: messagesStateStatus ?? this.messagesStateStatus,
      messages: messages ?? this.messages,
    );
  }

  List<AppContact> getFilteredContacts() {
    if (searchTerm.isEmpty) {
      return contacts;
    }

    return contacts
        .where((contact) =>
            contact.localContact.displayName.toLowerCase().contains(searchTerm))
        .toList();
  }

  @override
  List<Object?> get props => [
        searchTerm,
        contacts,
        contactsStateStatus,
        chatsStateStatus,
        users,
        chatsStateStatus,
        chats,
        messagesStateStatus,
        messages,
      ];
}
