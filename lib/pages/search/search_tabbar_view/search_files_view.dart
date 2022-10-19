import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/models/file/message_file.dart';
import 'package:twake/pages/search/search_tabbar_view/files/files_status_informer.dart';
import 'package:twake/widgets/common/file_channel_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchFilesView extends StatefulWidget {
  final bool isAllTab;
  SearchFilesView({this.isAllTab: false});
  @override
  State<SearchFilesView> createState() => _SearchFilesViewState();
}

class _SearchFilesViewState extends State<SearchFilesView>
    with AutomaticKeepAliveClientMixin<SearchFilesView> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: BlocBuilder<SearchCubit, SearchState>(
            bloc: Get.find<SearchCubit>(),
            builder: (context, state) {
              if (widget.isAllTab && state.files.length == 0) {
                return SizedBox.shrink();
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      state.files.length != 0 &&
                              state.filesStateStatus ==
                                  FilesStateStatus.doneRecent
                          ? AppLocalizations.of(context)!.recentFiles
                          : state.files.length != 0 &&
                                  state.filesStateStatus ==
                                      FilesStateStatus.done &&
                                  state.files.length != 0
                              ? AppLocalizations.of(context)!.files
                              : "",
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontSize: 15.0, fontWeight: FontWeight.w600)),
                ],
              );
            },
          ),
        ),
        widget.isAllTab ? _buildFiles() : Expanded(child: _buildFiles())
      ],
    );
  }

  Widget _buildFiles() {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: Get.find<SearchCubit>(),
      builder: (context, state) {
        if ((state.filesStateStatus == FilesStateStatus.done ||
                state.filesStateStatus == FilesStateStatus.doneRecent) &&
            state.files.isNotEmpty) {
          return widget.isAllTab
              ? FilesSection(
                  searchTerm: state.searchTerm,
                  files: state.files,
                  isAllTab: widget.isAllTab,
                )
              : SizedBox.expand(
                  child: FilesSection(
                    searchTerm: state.searchTerm,
                    files: state.files,
                    isAllTab: widget.isAllTab,
                  ),
                );
        }

        return widget.isAllTab
            ? SizedBox.shrink()
            : FileStatusInformer(
                status: state.filesStateStatus,
                searchTerm: state.searchTerm,
                onResetTap: () => Get.find<SearchCubit>().resetSearch());
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class FilesSection extends StatelessWidget {
  final List<MessageFile> files;
  final String searchTerm;
  final bool isAllTab;

  const FilesSection(
      {Key? key,
      required this.files,
      required this.isAllTab,
      required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: files.length,
      shrinkWrap: true,
      physics: isAllTab ? NeverScrollableScrollPhysics() : ScrollPhysics(),
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
