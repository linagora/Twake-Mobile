import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:equatable/equatable.dart';

import 'package:twake/blocs/messages_cubit/messages_cubit.dart';

import 'package:twake/repositories/messages_repository.dart';

part 'file_upload_transition_state.dart';

class FileUploadTransitionCubit extends Cubit<FileUploadTransitionState> {
  FileUploadTransitionCubit()
      : super(FileUploadTransitionState(
            fileUploadTransitionStatus:
                FileUploadTransitionStatus.uploadingMessageNotSent));

  void uploadingMessageSent(List<Message> messages) async {
    emit(state.copyWith(
        newMessages: messages,
        newFileUploadTransitionStatus:
            FileUploadTransitionStatus.uploadingMessageSent));
  }

  void uploadingMessageNotSent() async {
    emit(FileUploadTransitionState(
        fileUploadTransitionStatus:
            FileUploadTransitionStatus.uploadingMessageNotSent));
  }

  void uploadingDone() async {
    if (state.fileUploadTransitionStatus ==
        FileUploadTransitionStatus.uploadingMessageSent)
      Get.find<ChannelMessagesCubit>().startEdit(message: state.messages.first);
    if (state.fileUploadTransitionStatus ==
        FileUploadTransitionStatus.uploadingMessageNotSent) uploadingFinished();
  }

  void uploadingFinished() async {
    emit(FileUploadTransitionState(
        fileUploadTransitionStatus: FileUploadTransitionStatus.finished));
  }
}
