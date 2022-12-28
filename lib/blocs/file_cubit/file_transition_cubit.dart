import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/message_file.dart';
import 'package:twake/models/file/upload/file_uploading.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/messages_repository.dart';

part 'file_transition_state.dart';

class FileTransitionCubit extends Cubit<FileTransitionState> {
  late final ChannelMessagesCubit channelMessagesCubit;
  late final ThreadMessagesCubit threadMessagesCubit;
  late final FileUploadCubit fileUploadCubit;

  FileTransitionCubit(
      this.channelMessagesCubit, this.threadMessagesCubit, this.fileUploadCubit)
      : super(FileTransitionState(
            fileTransitionStatus: FileTransitionStatus.init)) {
    channelMessagesCubit.stream.listen((channelMState) {
      final uploadState = Get.find<FileUploadCubit>().state;
      if (channelMState is MessagesLoadSuccess &&
          channelMState is! MessageSendInProgress &&
          state.fileTransitionStatus ==
              FileTransitionStatus.messageInprogressFileLoading) {
        messageSentFileLoading(channelMState.messages);
      }
      if (channelMState is MessageEditInProgress &&
          state.fileTransitionStatus ==
              FileTransitionStatus.messageSentFileLoading) {
        // attaching the file to the message when it is well uploaded
        List<dynamic> attachments = uploadState.listFileUploading
            .where((fileUploading) => (fileUploading.file != null ||
                fileUploading.messageFile != null))
            .map((e) => e.messageFile != null
                ? e.messageFile!.toAttachment()
                : e.file!.toAttachment())
            .toList();
        Get.find<ChannelMessagesCubit>().edit(
            message: state.messages.first,
            editedText: state.messages.first.text,
            newAttachments: attachments);
        // start clearing
        Get.find<FileUploadCubit>().closeListUploadingStream();
        Get.find<FileUploadCubit>().clearFileUploadingState();
        fileTransitionFinished();
      }
    });
    threadMessagesCubit.stream.listen((threadMState) {
      final uploadState = Get.find<FileUploadCubit>().state;
      if (threadMState is MessagesLoadSuccess &&
          threadMState is! MessageSendInProgress &&
          state.fileTransitionStatus ==
              FileTransitionStatus.messageInprogressFileLoading) {
        messageSentFileLoading(threadMState.messages);
      }
      if (threadMState is MessageEditInProgress &&
          state.fileTransitionStatus ==
              FileTransitionStatus.messageSentFileLoading) {
        // attacing the file to the message when it is well uploaded
        List<dynamic> attachments = uploadState.listFileUploading
            .where((fileUploading) => (fileUploading.file != null ||
                fileUploading.messageFile != null))
            .map((e) => e.messageFile != null
                ? e.messageFile!.toAttachment()
                : e.file!.toAttachment())
            .toList();
        Get.find<ChannelMessagesCubit>().edit(
            message: state.messages.first,
            editedText: state.messages.first.text,
            newAttachments: attachments);
        // start clearing
        Get.find<FileUploadCubit>().closeListUploadingStream();
        Get.find<FileUploadCubit>().clearFileUploadingState();
        fileTransitionFinished();
      }
    });

    fileUploadCubit.stream.listen((uploadState) {
      final hasUploadedFileInStack = uploadState.listFileUploading.every(
          (element) => element.uploadStatus == FileItemUploadStatus.uploaded);
      sendFile() {
        final Channel? channel =
            (Get.find<ChannelsCubit>().state as ChannelsLoadedSuccess).selected;
        List<dynamic> attachments = uploadState.listFileUploading
            .where((fileUploading) => (fileUploading.file != null ||
                fileUploading.messageFile != null))
            .map((e) => e.messageFile != null
                ? e.messageFile!.toAttachment()
                : e.file!.toAttachment())
            .toList();
        Globals.instance.threadId == null
            ? Get.find<ChannelMessagesCubit>().send(
                originalStr: "",
                attachments: attachments,
                isDirect: channel == null ? true : channel.isDirect,
              )
            : Get.find<ThreadMessagesCubit>().send(
                threadId: Globals.instance.threadId,
                originalStr: "",
                attachments: attachments,
                isDirect: channel == null ? true : channel.isDirect,
              );
        // start clearing
        if (hasUploadedFileInStack) {
          Globals.instance.threadId == null
              ? Get.find<ChannelMessagesCubit>().removeFromState(dummyId)
              : Get.find<ThreadMessagesCubit>().removeFromState(dummyId);
          Get.find<FileUploadCubit>().closeListUploadingStream();
          Get.find<FileUploadCubit>().clearFileUploadingState();
          fileTransitionFinished();
        }
      }

      if (hasUploadedFileInStack &&
          state.fileTransitionStatus ==
              FileTransitionStatus.messageSentFileLoading) {
        // When the file is uploaded => edit message and attach the file
        startMessageEditting();
      }

      if (hasUploadedFileInStack &&
          state.fileTransitionStatus ==
              FileTransitionStatus.messageEmptyFileLoading) {
        // if file sent without a text, wait till it is well loaded and send an empty message with a file
        sendFile();
      }
      if (state.fileTransitionStatus ==
          FileTransitionStatus.noMessageTwakeFile) {
        // Twake File from Gallery
        sendFile();
      }
    });
  }

  void fileLoadingMessageEmpty() async {
    emit(state.copyWith(
        newFileUploadTransitionStatus:
            FileTransitionStatus.messageEmptyFileLoading));
  }

  void messageInprogressFileLoading() async {
    emit(FileTransitionState(
        fileTransitionStatus:
            FileTransitionStatus.messageInprogressFileLoading));
  }

  void noMessageTwakeFile() async {
    emit(FileTransitionState(
        fileTransitionStatus: FileTransitionStatus.noMessageTwakeFile));
  }

  void messageSentFileLoading(List<Message> messages) async {
    emit(FileTransitionState(
        fileTransitionStatus: FileTransitionStatus.messageSentFileLoading,
        messages: messages));
  }

  void startMessageEditting() async {
    Globals.instance.threadId == null
        ? Get.find<ChannelMessagesCubit>()
            .startEdit(message: state.messages.first)
        : Get.find<ThreadMessagesCubit>()
            .startEdit(message: state.messages.first);
  }

  void fileTransitionInit() async {
    emit(FileTransitionState(
      fileTransitionStatus: FileTransitionStatus.init,
    ));
  }

  void fileTransitionFinished() async {
    emit(FileTransitionState(
      fileTransitionStatus: FileTransitionStatus.finished,
    ));
  }
}
