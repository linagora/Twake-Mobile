import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/file/message_file.dart';
import 'package:twake/pages/search/search_tabbar_view/media/media_status_informer.dart';
import 'package:twake/widgets/common/file_channel_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchMediaView extends StatefulWidget {
  final bool isAllTab;
  SearchMediaView({this.isAllTab: false});
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: BlocBuilder<SearchCubit, SearchState>(
            bloc: Get.find<SearchCubit>(),
            builder: (context, state) {
              if (widget.isAllTab && state.medias.length == 0) {
                return SizedBox.shrink();
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      state.medias.length != 0 &&
                              state.mediaStateStatus ==
                                  MediaStateStatus.doneRecent
                          ? AppLocalizations.of(context)!.recentMedia
                          : state.medias.length != 0 &&
                                  state.mediaStateStatus ==
                                      MediaStateStatus.done
                              ? AppLocalizations.of(context)!.media
                              : '',
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontSize: 15.0, fontWeight: FontWeight.w600)),
                ],
              );
            },
          ),
        ),
        widget.isAllTab ? _buildMedia() : Expanded(child: _buildMedia()),
      ],
    );
  }

  Widget _buildMedia() {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: Get.find<SearchCubit>(),
      builder: (context, state) {
        if (state.mediaStateStatus == MediaStateStatus.doneRecent &&
            state.medias.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: GridView.builder(
                key: PageStorageKey<String>('mediaDone'),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                ),
                shrinkWrap: true,
                physics: widget.isAllTab
                    ? NeverScrollableScrollPhysics()
                    : ScrollPhysics(),
                itemCount: state.medias.length,
                itemBuilder: (_, index) {
                  return FileChannelTile(
                    fileId: state.medias[index].id,
                    senderName: state.medias[index].user == null
                        ? ""
                        : state.medias[index].user!.fullName,
                    messageFile: state.medias[index],
                    onlyImage: true,
                    fileTileHeight: Dim.wm30,
                  );
                },
              ),
            ),
          );
        }
        if (state.mediaStateStatus == MediaStateStatus.done &&
            state.medias.isNotEmpty) {
          return widget.isAllTab
              ? MediasSection(
                  searchTerm: state.searchTerm,
                  files: state.medias,
                  isAlltab: widget.isAllTab,
                )
              : SizedBox.expand(
                  child: MediasSection(
                  searchTerm: state.searchTerm,
                  files: state.medias,
                  isAlltab: widget.isAllTab,
                ));
        }
        return widget.isAllTab
            ? SizedBox.shrink()
            : MediaStatusInformer(
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
  final List<MessageFile> files;
  final String searchTerm;
  final bool isAlltab;

  const MediasSection(
      {Key? key,
      required this.files,
      required this.isAlltab,
      required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: files.length,
      shrinkWrap: true,
      physics: isAlltab ? NeverScrollableScrollPhysics() : ScrollPhysics(),
      itemBuilder: (context, index) {
        return FileChannelTile(
            fileId: files[index].id,
            senderName:
                files[index].user == null ? "" : files[index].user!.fullName,
            messageFile: files[index]);
      },
    );
  }
}
