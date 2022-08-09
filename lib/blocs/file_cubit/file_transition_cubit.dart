import 'package:bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:equatable/equatable.dart';

import 'package:twake/blocs/messages_cubit/messages_cubit.dart';

import 'package:twake/repositories/messages_repository.dart';

part 'file_transition_state.dart';

class FileTransitionCubit extends Cubit<FileTransitionState> {
  FileTransitionCubit()
      : super(FileTransitionState(
            fileTransitionStatus: FileTransitionStatus.init));

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
    Get.find<ChannelMessagesCubit>().startEdit(message: state.messages.first);
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
