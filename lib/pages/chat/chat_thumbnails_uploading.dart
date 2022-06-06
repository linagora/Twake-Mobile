import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/file_cubit/file_upload_transition_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/pages/chat/chat_attachment.dart';

class ChatThumbnailsUploading extends StatelessWidget {
  const ChatThumbnailsUploading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileUploadTransitionCubit, FileUploadTransitionState>(
      bloc: Get.find<FileUploadTransitionCubit>(),
      builder: (context, state) {
        return state.fileUploadTransitionStatus !=
                FileUploadTransitionStatus.uploadingMessageSent
            ? BlocBuilder<FileUploadCubit, FileUploadState>(
                bloc: Get.find<FileUploadCubit>(),
                builder: (context, state) {
                  if (state.fileUploadStatus == FileUploadStatus.inProcessing) {
                    return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        height: 100,
                        width: 285,
                        child: ChatAttachment());
                  } else {
                    return SizedBox.shrink();
                  }
                },
              )
            : SizedBox.shrink();
      },
    );
  }
}
