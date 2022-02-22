
import 'package:equatable/equatable.dart';

enum SyncFailedSource {
  AccountApi,
  CompaniesApi,
  WorkspacesApi,
  ChannelsDirectApi,
  ChannelsApi,
  WorkspaceMembersApi,
  ThreadsApi
}

abstract class SyncDataState extends Equatable {
  const SyncDataState();
}

class SyncDataSuccessState extends SyncDataState {
  final int process;
  const SyncDataSuccessState({required this.process});

  @override
  List<Object?> get props => [process];
}

class SyncDataFailState extends SyncDataState {
  final SyncFailedSource failedSource;
  const SyncDataFailState({required this.failedSource});

  @override
  List<Object?> get props => [failedSource];
}
