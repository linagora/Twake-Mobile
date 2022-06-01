import 'package:equatable/equatable.dart';

class ChannelFile extends Equatable {
  final String fileId;
  final String senderName;
  final String fileName;
  final int createdAt;

  ChannelFile({
    required this.fileId,
    required this.senderName,
    this.fileName: '',
    required this.createdAt,
  });

  @override
  List<Object> get props => [fileId, senderName, fileName, createdAt];
}
