import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_state.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';
import 'package:twake/repositories/channels_repository.dart';
import 'package:twake/repositories/companies_repository.dart';
import 'package:twake/repositories/workspaces_repository.dart';

class ReceiveFileCubit extends Cubit<ReceiveShareFileState> {
  late final CompaniesRepository _companyRepository;
  late final WorkspacesRepository _workspaceRepository;
  late final ChannelsRepository _channelRepository;

  ReceiveFileCubit({
    CompaniesRepository? compRepository,
    WorkspacesRepository? workspacesRepository,
    ChannelsRepository? channelRepository,
  }) : super(const ReceiveShareFileState()) {
    if (compRepository == null) {
      _companyRepository = CompaniesRepository();
    } else {
      _companyRepository = compRepository;
    }
    if (workspacesRepository == null) {
      _workspaceRepository = WorkspacesRepository();
    } else {
      _workspaceRepository = workspacesRepository;
    }
    if (channelRepository == null) {
      _channelRepository = ChannelsRepository();
    } else {
      _channelRepository = channelRepository;
    }
  }

  void setNewListFiles(List<ReceiveSharingFile> listFiles) {
    emit(state.copyWith(newStatus: ReceiveShareFileStatus.inProcessing, newListFiles: listFiles));

    // TODO: fetch all companies
    // TODO: fetch all workspaces
    // TODO: fetch all channels

    // TODO: set selected state to items in list
  }
}
