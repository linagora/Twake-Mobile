import 'package:flutter/material.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/widgets/common/no_search_results_widget.dart';

class ChatsStatusInformer extends StatelessWidget {
  final ChatsStateStatus status;
  final String searchTerm;
  final Function onResetTap;

  const ChatsStatusInformer(
      {Key? key,
      required this.status,
      required this.searchTerm,
      required this.onResetTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status == ChatsStateStatus.loading || status == ChatsStateStatus.init) {
      return Center(
        child: Container(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return NoSearchResultsWidget(
        searchTerm: searchTerm, onResetTap: onResetTap);
  }
}
