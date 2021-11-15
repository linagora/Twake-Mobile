import 'package:equatable/equatable.dart';

class WorkspaceJoinRequest with EquatableMixin {

  final bool join;
  final String token;

  const WorkspaceJoinRequest(this.join, this.token);

  @override
  List<Object> get props => [join, token];

}