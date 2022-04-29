import 'package:equatable/equatable.dart';

class TwakeLinkJoining extends Equatable {
  final String companyId;
  final String workspaceId;
  final String channelId;

  TwakeLinkJoining(this.companyId, this.workspaceId, this.channelId);

  @override
  List<Object> get props => [companyId, workspaceId, channelId];
}
