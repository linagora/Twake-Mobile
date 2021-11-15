import 'package:equatable/equatable.dart';

enum InvitationStatus {
  init,
  inProcessing,
  generateLinkSuccess,
  generateLinkFail
}

class InvitationState extends Equatable {
  final InvitationStatus status;
  final String link;

  const InvitationState({
    this.status = InvitationStatus.init,
    this.link = ''
  });

  InvitationState copyWith({
    InvitationStatus? newStatus,
    String? newLink
  }) {
    return InvitationState(
      status: newStatus ?? this.status,
      link: newLink ?? this.link
    );
  }

  @override
  List<Object> get props => [status, link];
}
