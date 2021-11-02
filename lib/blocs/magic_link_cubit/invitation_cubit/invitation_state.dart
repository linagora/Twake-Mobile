import 'package:equatable/equatable.dart';
import 'package:twake/models/deeplink/magic_link.dart';

enum InvitationStatus {
  init,
  inProcessing,
  generateLinkSuccess,
  generateLinkFail
}

class InvitationState extends Equatable {
  final InvitationStatus status;
  final MagicLink link;

  const InvitationState({
    this.status = InvitationStatus.init,
    this.link = const MagicLink.init()
  });

  InvitationState copyWith({
    InvitationStatus? newStatus,
    MagicLink? newLink
  }) {
    return InvitationState(
      status: newStatus ?? this.status,
      link: newLink ?? this.link
    );
  }

  @override
  List<Object> get props => [status, link];
}
