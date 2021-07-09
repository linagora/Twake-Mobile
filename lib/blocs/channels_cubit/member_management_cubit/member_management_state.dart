import 'package:equatable/equatable.dart';

abstract class MemberManagementState with EquatableMixin {
  const MemberManagementState();

  @override
  List<Object?> get props => [];
}

class MemberManagementInitial extends MemberManagementState {
  const MemberManagementInitial();
}
