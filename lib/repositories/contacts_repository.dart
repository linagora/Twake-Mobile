import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:twake/models/contacts/app_contact.dart';
import 'package:twake/services/service_bundle.dart';

class ContactsRequest {
  final List<AppContact> contacts;
  final bool hasError;
  final bool hasPermissions;

  ContactsRequest(
      {required this.hasPermissions,
      required this.contacts,
      required this.hasError});
}

class ContactsRepository {
  Future<ContactsRequest> fetchAllContacts() async {
    final hasPermissions = await FlutterContacts.requestPermission();

    if (!hasPermissions) {
      return ContactsRequest(
          hasPermissions: false, contacts: [], hasError: true);
    }

    try {
      final contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);

      return ContactsRequest(
          contacts: contacts.map((e) => AppContact(localContact: e)).toList(),
          hasPermissions: true,
          hasError: false);
    } catch (e) {
      Logger().e('Error occurred while fetching contacts:\n$e');

      return ContactsRequest(
          hasPermissions: true, contacts: [], hasError: true);
    }
  }
}
