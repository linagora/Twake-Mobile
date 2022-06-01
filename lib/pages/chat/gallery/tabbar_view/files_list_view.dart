import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/company_files_cubit/company_file_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/channel/channel_file.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/local_file.dart';
import 'package:twake/utils/constants.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/utils/utilities.dart';
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
  String _searchText = "";
  @override
  void initState() {
    super.initState();

    Get.find<CompanyFileCubit>().getCompanyFiles();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  void _handlePickLocalFile() async {
    List<PlatformFile>? platformFiles =
        await Utilities.pickFiles(context: context, fileType: FileType.any);

    if (!mounted) return;
    if (platformFiles == null) return;

    final countUploading =
        Get.find<FileUploadCubit>().state.listFileUploading.length;
    final remainingAllowFile = MAX_FILE_UPLOADING - countUploading;
    if (platformFiles.length > remainingAllowFile) {
      platformFiles = platformFiles.getRange(0, remainingAllowFile).toList();
    }

    for (var i = 0; i < platformFiles.length; i++) {
      LocalFile localFile = platformFiles[i].toLocalFile();
      localFile =
          localFile.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);

      Get.find<FileUploadCubit>().upload(
        sourceFile: localFile,
        sourceFileUploading: SourceFileUploading.InChat,
      );
    }

    Get.back();
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
                GestureDetector(
                  onTap: _handlePickLocalFile,
                  child: Row(
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
                      final files = _searchText.isEmpty
                          ? state.files
                          : state.files.where((file) {
                              return file.fileName
                                  .toLowerCase()
                                  .contains(_searchText);
                            }).toList();
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: files.length,
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
                          return _buildChannelFileItem(files[index]);
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

  _handleSelectFile(File file) {
    Get.find<FileUploadCubit>().addAlreadyUploadedFile(
      existsFile: file,
    );

    Get.back();
  }

  _buildChannelFileItem(ChannelFile channelFile) {
    return FileChannelTile(
      fileId: channelFile.fileId,
      senderName: channelFile.senderName,
      onTap: (file) => _handleSelectFile(file),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
