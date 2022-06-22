import 'package:equatable/equatable.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/models/contacts/app_contact.dart';

enum ContactsStateStatus { init, loading, done, failed, noPermission }

class SearchState extends Equatable {
  final String searchTerm;

  final ContactsStateStatus contactsStateStatus;
  final List<AppContact> contacts;
  final List<Account> users;

  const SearchState(
      {required this.searchTerm,
      required this.users,
      required this.contactsStateStatus,
      required this.contacts});

  factory SearchState.initial() {
    return SearchState(
        searchTerm: '',
        contactsStateStatus: ContactsStateStatus.init,
        users: [],
        contacts: []);
  }

  SearchState copyWith({
    final String? searchTerm,
    final ContactsStateStatus? contactsStateStatus,
    final List<AppContact>? contacts,
    final List<Account>? users,
  }) {
    return SearchState(
      searchTerm: searchTerm ?? this.searchTerm,
      contactsStateStatus: contactsStateStatus ?? this.contactsStateStatus,
      contacts: contacts ?? this.contacts,
      users: users ?? this.users,
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
      ];
}
