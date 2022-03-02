import 'package:equatable/equatable.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';

enum ReceiveShareFileStatus {
  init,
  inProcessing,
  successful,
  failed
}

class ReceiveShareFileState extends Equatable {
  final ReceiveShareFileStatus status;
  final List<ReceiveSharingFile> listFiles;

  const ReceiveShareFileState({
    this.status = ReceiveShareFileStatus.init,
    this.listFiles = const []
  });

  ReceiveShareFileState copyWith({
    ReceiveShareFileStatus? newStatus,
    List<ReceiveSharingFile>? newListFiles
  }) {
    return ReceiveShareFileState(
      status: newStatus ?? this.status,
      listFiles: newListFiles ?? this.listFiles
    );
  }

  @override
  List<Object> get props => [status, listFiles];
}
