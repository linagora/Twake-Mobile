part of 'file_upload_transition_cubit.dart';

enum FileUploadTransitionStatus {
  uploadingMessageNotSent,
  uploadingMessageSent,
  finished,
}

class FileUploadTransitionState extends Equatable {
  final FileUploadTransitionStatus fileUploadTransitionStatus;
  final List<Message> messages;

  const FileUploadTransitionState({
    this.fileUploadTransitionStatus =
        FileUploadTransitionStatus.uploadingMessageNotSent,
    this.messages = const [],
  });

  FileUploadTransitionState copyWith({
    FileUploadTransitionStatus? newFileUploadTransitionStatus,
    List<Message>? newMessages,
  }) {
    return FileUploadTransitionState(
        fileUploadTransitionStatus:
            newFileUploadTransitionStatus ?? this.fileUploadTransitionStatus,
        messages: newMessages ?? this.messages);
  }

  @override
  List<Object?> get props => [fileUploadTransitionStatus, messages];
}
