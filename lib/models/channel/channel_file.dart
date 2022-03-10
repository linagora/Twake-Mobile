import 'package:equatable/equatable.dart';

class ChannelFile extends Equatable {
  final String fileId;
  final String senderName;

  ChannelFile(this.fileId, this.senderName);

  @override
  List<Object> get props => [fileId, senderName];
}
