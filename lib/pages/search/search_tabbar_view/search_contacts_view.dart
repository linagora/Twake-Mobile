import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/pages/search/search_tabbar_view/contacts/app_contact_tile.dart';

class SearchContactsView extends StatefulWidget {
  @override
  State<SearchContactsView> createState() => _SearchContactsViewState();
}

class _SearchContactsViewState extends State<SearchContactsView> {
  @override
  void initState() {
    super.initState();

    Get.find<SearchCubit>().getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: Get.find<SearchCubit>(),
      builder: (context, state) {
        final contacts = state.getFilteredContacts();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return AppContactTile(userId: null, contact: contact);
          },
        );
      },
    );
  }
}
