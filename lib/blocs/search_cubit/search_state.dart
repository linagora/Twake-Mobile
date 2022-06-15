import 'package:equatable/equatable.dart';
import 'package:twake/models/contacts/app_contact.dart';

enum ContactsStateStatus { init, loading, done, failed, noPermission }

class SearchState extends Equatable {
  final String searchTerm;

  final ContactsStateStatus contactsStateStatus;
  final List<AppContact> contacts;

  const SearchState(
      {required this.searchTerm,
      required this.contactsStateStatus,
      required this.contacts});

  factory SearchState.initial() {
    return SearchState(
        searchTerm: '',
        contactsStateStatus: ContactsStateStatus.init,
        contacts: []);
  }

  SearchState copyWith({
    final String? searchTerm,
    final ContactsStateStatus? contactsStateStatus,
    final List<AppContact>? contacts,
  }) {
    return SearchState(
      searchTerm: searchTerm ?? this.searchTerm,
      contactsStateStatus: contactsStateStatus ?? this.contactsStateStatus,
      contacts: contacts ?? this.contacts,
    );
  }

  @override
  List<Object?> get props => [
        searchTerm,
        contacts,
        contactsStateStatus,
      ];
}
