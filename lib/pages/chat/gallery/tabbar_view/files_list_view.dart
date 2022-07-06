import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/company_files_cubit/company_file_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/local_file.dart';
import 'package:twake/models/file/message_file.dart';
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

      if (localFile.isImageFile) {
        final Uint8List thumbnail = platformFiles[i].bytes!;
        // if local file have thumbnail then file_tile.dart will display it
        localFile = localFile.copyWith(thumbnail: thumbnail);
      }

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
                  hintText: AppLocalizations.of(context)!.searchForFiles,
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
                          AppLocalizations.of(context)!.addLocalStorageFile,
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
                  AppLocalizations.of(context)!.twakeFiles,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                BlocBuilder<CompanyFileCubit, CompanyFileState>(
                  bloc: Get.find<CompanyFileCubit>(),
                  builder: (context, state) {
                    if (state.companyFileStatus == CompanyFileStatus.done) {
                      // user doesn't have any uploaded file
                      if (state.files.isEmpty) {
                        return CompanyFilesStatusInformer(
                            companyFileStatus: CompanyFileStatus.empty);
                      }

                      final files = _searchText.isEmpty
                          ? state.files
                          : state.files.where((file) {
                              return file.metadata.name
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
                      return CompanyFilesStatusInformer(
                          companyFileStatus: state.companyFileStatus);
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

  void _handleSelectFile(dynamic file) {
    file.runtimeType == MessageFile
        ? Get.find<FileUploadCubit>().addAlreadyUploadedFile(
            existsMessageFile: (file as MessageFile),
          )
        : Get.find<FileUploadCubit>().addAlreadyUploadedFile(
            existsFile: (file as File),
          );

    Get.back();
  }

  _buildChannelFileItem(MessageFile messageFile) {
    return FileChannelTile(
      fileId: messageFile.id,
      senderName: messageFile.user.fullName,
      onTap: (file) => _handleSelectFile(file),
      messageFile: messageFile,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CompanyFilesStatusInformer extends StatelessWidget {
  final CompanyFileStatus companyFileStatus;

  const CompanyFilesStatusInformer({Key? key, required this.companyFileStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? header;
    String headerText = '';
    String messageText = '';

    switch (companyFileStatus) {
      case CompanyFileStatus.empty:
        header = Image.asset(
          imageDownload_x2,
        );
        headerText =
            headerText = AppLocalizations.of(context)!.noCompanyFilesHeader;
        break;
      case CompanyFileStatus.loading:
        header = CircularProgressIndicator();
        headerText =
            AppLocalizations.of(context)!.loadingHeaderDuringCompanyFiles;
        messageText =
            AppLocalizations.of(context)!.loadingMessageDuringCompanyFiles;
        break;
      default:
        header = Image.asset(imageError_x2);
        headerText =
            AppLocalizations.of(context)!.errorHeaderDuringCompanyFiles;
        messageText =
            AppLocalizations.of(context)!.errorMessageDuringCompanyFiles;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        children: [
          header,
          SizedBox(
            height: 16,
          ),
          Text(headerText,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontSize: 20, fontWeight: FontWeight.w600)),
          SizedBox(
            height: 8,
          ),
          Text(messageText,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
