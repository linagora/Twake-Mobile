import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/company_files_cubit/company_file_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/channel/channel_file.dart';
import 'package:twake/widgets/common/file_channel_tile.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

class FilesListView extends StatefulWidget {
  final ScrollController scrollController;

  FilesListView({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<FilesListView> createState() => _FilesListViewState();
}

class _FilesListViewState extends State<FilesListView>
    with AutomaticKeepAliveClientMixin<FilesListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Get.find<CompanyFileCubit>().getCompanyFiles();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      controller: widget.scrollController,
      children: [
        Container(
          color: Get.isDarkMode
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TwakeSearchTextField(
                  height: 40,
                  controller: _searchController,
                  hintText: AppLocalizations.of(context)!.search,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.add,
                      size: 32,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Add local storage file",
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Twake files",
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                BlocBuilder<CompanyFileCubit, CompanyFileState>(
                  bloc: Get.find<CompanyFileCubit>(),
                  builder: (context, state) {
                    if (state.companyFileStatus == CompanyFileStatus.done) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shrinkWrap: true,
                        itemCount: state.files.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Padding(
                          padding: EdgeInsets.only(
                              left: Dim.widthPercent(25), top: 6, bottom: 6),
                          child: Divider(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.3),
                            height: 1,
                          ),
                        ),
                        itemBuilder: (context, index) {
                          return _buildChannelFileItem(state.files[index]);
                        },
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  _buildChannelFileItem(ChannelFile channelFile) {
    return FileChannelTile(
      fileId: channelFile.fileId,
      senderName: channelFile.senderName,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
