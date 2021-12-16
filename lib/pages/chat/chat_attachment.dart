import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/file/upload/file_uploading.dart';
import 'package:twake/utils/constants.dart';
import 'package:twake/widgets/common/file_uploading_tile.dart';

class ChatAttachment extends StatefulWidget {
  final String senderName;
  const ChatAttachment({Key? key, required this.senderName}) : super(key: key);

  @override
  _ChatAttachmentState createState() => _ChatAttachmentState();
}

class _ChatAttachmentState extends State<ChatAttachment> {

  @override
  void initState() {
    super.initState();
    Get.find<FileUploadCubit>().stream.listen((state) {
      if (state.listFileUploading.isNotEmpty) {
        final listUploadFailed = state.listFileUploading
            .where((element) =>
                element.uploadStatus == FileItemUploadStatus.failed)
            .toList();
        if(listUploadFailed.isNotEmpty) {
          final listName = listUploadFailed.map(
              (e) => e.sourceFile?.name).toList();
          _showUploadFailedPopup(
            listName.join(',').toString(),
            listUploadFailed,
          );
        }
      }
    });
  }

  _showUploadFailedPopup(String fileName, List<FileUploading> listUploadFailed) {
    Get.snackbar('', '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        animationDuration: Duration(milliseconds: 500),
        duration: const Duration(milliseconds: 1500),
        icon: Image.asset(imageError, width: 24, height: 24),
        titleText: Text(
          fileName,
          maxLines: 1,
          style: StylesConfig.commonTextStyle.copyWith(
            fontSize: 17,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        messageText: Text(
          AppLocalizations.of(context)?.fileUploadFailed ?? '',
          style: StylesConfig.commonTextStyle
              .copyWith(fontSize: 12, color: const Color(0xffe64646)),
        ),
        boxShadows: [
          BoxShadow(
            blurRadius: 16,
            color: Color.fromRGBO(0, 0, 0, 0.24),
          )
        ],
        mainButton: TextButton(
          onPressed: () {
            Get.find<FileUploadCubit>().retryUpload(listUploadFailed);
          },
          child: Text(AppLocalizations.of(context)?.tryAgain ?? '',
            style: StylesConfig.commonTextStyle.copyWith(
              fontSize: 14.0,
              color: const Color(0xff004dff),
              fontWeight: FontWeight.w500
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: const Color(0xffF2F2F6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCloseButton(),
          SizedBox(height: 24.0),
          Expanded(
            child: Container(
              child: _buildListFiles(),
            ),
          ),
          SizedBox(height: 10.0),
          _buildDestination()
        ],
      ),
    );
  }

  _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        Get.find<FileUploadCubit>().clearFileUploadingState(
          needToCancelInProcessingFile: true
        );
      },
      child: Image.asset(
        imageClose,
        width: 24.0,
        height: 24.0,
      ),
    );
  }

  _buildListFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.attachedFiles ?? '',
          style: StylesConfig.commonTextStyle.copyWith(
              color: const Color.fromRGBO(0, 0, 0, 0.35),
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          AppLocalizations.of(context)?.attachedFilesHint(MAX_FILE_UPLOADING.toString()) ?? '',
          style: StylesConfig.commonTextStyle.copyWith(
              color: const Color(0xff969ca4),
              fontSize: 12.0
          ),
        ),
        SizedBox(height: 16.0),
        Flexible(
          child: BlocBuilder<FileUploadCubit, FileUploadState>(
              bloc: Get.find<FileUploadCubit>(),
              builder: (context, state) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.listFileUploading.length,
                    itemBuilder: (context, index) {
                      final fileUploading = state.listFileUploading[index];
                      return FileUploadingTile(
                          fileUploading: fileUploading,
                          onCancel: () {
                            Get.find<FileUploadCubit>().removeFileUploading(fileUploading);
                          }
                      );
                    });
              }
          ),
        )
      ],
    );
  }

  _buildDestination() {
    if(widget.senderName.isEmpty) {
      return SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image.asset(imageSendTo),
        SizedBox(width: 4.0),
        Text(
          widget.senderName,
          style: StylesConfig.commonTextStyle.copyWith(
              color: const Color(0xff4a4a4a),
              fontSize: 11.0
          ),
        ),
      ],
    );
  }

}
