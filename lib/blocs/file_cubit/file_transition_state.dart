part of 'file_transition_cubit.dart';

enum FileTransitionStatus {
  init,
  messageEmptyFileLoading,
  messageInprogressFileLoading,
  messageSentFileLoading,
  finished,
}

class FileTransitionState extends Equatable {
  final FileTransitionStatus fileTransitionStatus;
  final List<Message> messages;

  const FileTransitionState({
    this.fileTransitionStatus = FileTransitionStatus.init,
    this.messages = const [],
  });

  FileTransitionState copyWith({
    FileTransitionStatus? newFileUploadTransitionStatus,
    List<Message>? newMessages,
  }) {
    return FileTransitionState(
        fileTransitionStatus:
            newFileUploadTransitionStatus ?? this.fileTransitionStatus,
        messages: newMessages ?? this.messages);
  }

  @override
  List<Object?> get props => [fileTransitionStatus, messages];
}
