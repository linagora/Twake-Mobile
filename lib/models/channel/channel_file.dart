import 'package:equatable/equatable.dart';

class ChannelFile extends Equatable {
  final String fileId;
  final String senderName;
  final int createdAt;

  ChannelFile(this.fileId, this.senderName, this.createdAt);

  @override
  List<Object> get props => [fileId, senderName, createdAt];
}
