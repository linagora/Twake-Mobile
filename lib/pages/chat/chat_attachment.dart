import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/upload/file_uploading.dart';
import 'package:twake/widgets/common/file_uploading_tile.dart';

class ChatAttachment extends StatefulWidget {
  const ChatAttachment({Key? key}) : super(key: key);

  @override
  _ChatAttachmentState createState() => _ChatAttachmentState();
}

class _ChatAttachmentState extends State<ChatAttachment> {
  bool _isFailedPopupShown = false;

  @override
  void initState() {
    super.initState();
    Get.find<FileUploadCubit>().initFileUploadingStream();
    Get.find<FileUploadCubit>().streamListUploading.listen((file) {
      if (file.uploadStatus == FileItemUploadStatus.failed &&
          !_isFailedPopupShown) {
        final fileName = file.sourceFile?.name ?? '';
        _showUploadFailedPopup(fileName, [file]);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _showUploadFailedPopup(
      String fileName, List<FileUploading> listUploadFailed) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      animationDuration: Duration(milliseconds: 500),
      duration: const Duration(milliseconds: 4000),
      icon: Image.asset(imageError, width: 24, height: 24),
      titleText: Text(fileName,
          maxLines: 1,
          style: Theme.of(context).textTheme.headline1!.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.normal,
              overflow: TextOverflow.ellipsis)),
      messageText: Text(AppLocalizations.of(context)?.fileUploadFailed ?? '',
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
      boxShadows: [
        BoxShadow(
          blurRadius: 16,
          color: Color.fromRGBO(0, 0, 0, 0.24),
        )
      ],
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // dismiss this snackbar
          Get.find<FileUploadCubit>().retryUpload(
            listUploadFailed,
            sourceFileUploading: SourceFileUploading.InChat,
          );
        },
        child: Text(AppLocalizations.of(context)?.tryAgain ?? '',
            style: Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(fontSize: 15, fontWeight: FontWeight.normal)),
      ),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          _isFailedPopupShown = false;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileUploadCubit, FileUploadState>(
        bloc: Get.find<FileUploadCubit>(),
        builder: (context, state) {
          return state.fileUploadStatus != FileUploadStatus.init
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  // shrinkWrap: true,
                  itemCount: state.listFileUploading.length,
                  itemBuilder: (context, index) {
                    final fileUploading = state.listFileUploading[index];

                    final isRemoteFile = fileUploading.file != null &&
                        fileUploading.sourceFile == null;

                    final onCancel = () {
                      Get.find<FileUploadCubit>()
                          .removeFileUploading(fileUploading);
                    };

                    if (isRemoteFile) {
                      return FileUploadingTile(
                          thumbnailUrl: fileUploading.file!.thumbnailUrl,
                          fileUploading: fileUploading,
                          onCancel: onCancel);
                    }

                    return FileUploadingTile(
                        thumbnail: fileUploading.sourceFile!.thumbnail,
                        fileUploading: fileUploading,
                        onCancel: onCancel);
                  })
              : SizedBox.shrink();
        });
  }
}
