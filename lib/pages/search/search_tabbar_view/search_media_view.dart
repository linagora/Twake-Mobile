import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/pages/search/search_tabbar_view/media/media_item.dart';
import 'package:twake/pages/search/search_tabbar_view/media/media_status_informer.dart';
import 'package:twake/repositories/search_repository.dart';

class SearchMediaView extends StatefulWidget {
  @override
  State<SearchMediaView> createState() => _SearchMediaViewState();
}

class _SearchMediaViewState extends State<SearchMediaView>
    with AutomaticKeepAliveClientMixin<SearchMediaView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<SearchCubit, SearchState>(
      bloc: Get.find<SearchCubit>(),
      builder: (context, state) {
        if (state.mediaStateStatus == FilesStateStatus.done &&
            state.files.isNotEmpty) {
          return SizedBox.expand(
            child: ListView(children: [
              MediasSection(
                searchTerm: state.searchTerm,
                medias: state.medias,
              )
            ]),
          );
        }

        return MediaStatusInformer(
            status: state.mediaStateStatus,
            searchTerm: state.searchTerm,
            onResetTap: () => Get.find<SearchCubit>().resetSearch());
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MediasSection extends StatelessWidget {
  final List<SearchMedia> medias;
  final String searchTerm;

  const MediasSection(
      {Key? key, required this.medias, required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: medias.length,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemBuilder: (context, index) {
        return MediaItem(
          searchTerm: searchTerm,
          message: medias[index].message,
          file: medias[index].file,
          user: medias[index].user,
          //channel: files[index].channel,
        );
      },
    );
  }
}
