import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';

class SearchContactsView extends StatefulWidget {
  @override
  State<SearchContactsView> createState() => _SearchContactsViewState();
}

class _SearchContactsViewState extends State<SearchContactsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: Get.find<SearchCubit>(),
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            return Text(index.toString());
          },
        );
      },
    );
  }
}
