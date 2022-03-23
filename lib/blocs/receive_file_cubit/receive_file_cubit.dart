import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_state.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/common/selectable_item.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';
import 'package:twake/models/workspace/workspace.dart';
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

  void setNewListFiles(List<ReceiveSharingFile> listFiles) async {
    emit(state.copyWith(newListFiles: listFiles));

    final selectedComp = await fetchCompanies();
    if (selectedComp != null) {
      final selectedWS = await fetchWorkspaces(companyId: selectedComp.id);
      if (selectedWS != null) {
        await fetchChannels(
          companyId: selectedComp.id,
          workspaceId: selectedWS.id,
        );
      }
    }
  }

  Future<Company?> fetchCompanies({int? limit}) async {
    final streamCompanies = _companyRepository.fetch();
    Company? selected;
    await for (var companies in streamCompanies) {
      if (companies.isNotEmpty) {
        selected = companies.first;
        final companiesLimited = (limit != null) ? companies.take(limit) : companies;
        final selectableList = companiesLimited.map((e) {
          return e.id == companies.first.id
              ? SelectableItem(e, SelectState.SELECTED)
              : SelectableItem(e, SelectState.NONE);
        }).toList();
        emit(state.copyWith(newListCompanies: selectableList));
      } else {
        emit(state.copyWith(newListCompanies: []));
      }
    }
    return selected;
  }

  Future<Workspace?> fetchWorkspaces({
    required String companyId,
    int? limit,
  }) async {
    final streamWS = _workspaceRepository.fetch(companyId: companyId);
    Workspace? selected;
    await for (var workspaces in streamWS) {
      if (workspaces.isNotEmpty) {
        selected = workspaces.first;
        final workspacesLimited = (limit != null) ? workspaces.take(limit) : workspaces;
        final selectableList = workspacesLimited.map((e) {
          return e.id == workspaces.first.id
              ? SelectableItem(e, SelectState.SELECTED)
              : SelectableItem(e, SelectState.NONE);
        }).toList();
        emit(state.copyWith(newListWorkspaces: selectableList));
      } else {
        emit(state.copyWith(newListWorkspaces: []));
      }
    }
    return selected;
  }

  Future<Channel?> fetchChannels({
    required String companyId,
    required String workspaceId,
    int? limit,
  }) async {
    final streamGroupChannel = _channelRepository.fetch(
      companyId: companyId,
      workspaceId: workspaceId,
    );
    final streamDirectChannel = _channelRepository.fetch(
      companyId: companyId,
      workspaceId: 'direct',
    );
    final allChannels = Rx.zip2(
        streamGroupChannel, streamDirectChannel, (List<Channel> a, List<Channel> b) => a + b);

    Channel? selected;
    await for (var channels in allChannels) {
      if (channels.isNotEmpty) {
        selected = channels.first;
        final channelsLimited = (limit != null) ? channels.take(limit) : channels;
        final selectableList = channelsLimited.map((e) {
          return e.id == channels.first.id
              ? SelectableItem(e, SelectState.SELECTED)
              : SelectableItem(e, SelectState.NONE);
        }).toList();
        emit(state.copyWith(newListChannels: selectableList));
      } else {
        emit(state.copyWith(newListChannels: []));
      }
    }
    return selected;
  }

  void setSelectedCompany(Company company) async {
    final clickOnSelectedComp = state.listCompanies
        .any((e) => e.state == SelectState.SELECTED && e.element.id == company.id);
    if (clickOnSelectedComp)
      return;

    // Update selection state on UI
    final updateList = state.listCompanies.map((com) {
      return com.element.id == company.id
          ? SelectableItem(com.element, SelectState.SELECTED)
          : SelectableItem(com.element, SelectState.NONE);
    }).toList();
    emit(state.copyWith(newListCompanies: updateList));

    // re-fetch workspaces
    final selectedWS = await fetchWorkspaces(companyId: company.id);
    if (selectedWS != null) {
      await fetchChannels(
        companyId: company.id,
        workspaceId: selectedWS.id,
      );
    }
  }

  void setSelectedWS(Workspace workspace) async {
    final clickOnSelectedWS = state.listWorkspaces
        .any((e) => e.state == SelectState.SELECTED && e.element.id == workspace.id);
    if (clickOnSelectedWS)
      return;

    // Update selection state on UI
    final updateList = state.listWorkspaces.map((ws) {
      return ws.element.id == workspace.id
          ? SelectableItem(ws.element, SelectState.SELECTED)
          : SelectableItem(ws.element, SelectState.NONE);
    }).toList();
    emit(state.copyWith(newListWorkspaces: updateList));

    // re-fetch channels
    final currentSelectedComp =
        state.listCompanies
            .firstWhere((comp) => comp.state == SelectState.SELECTED)
            .element;
    await fetchChannels(
      companyId: currentSelectedComp.id,
      workspaceId: workspace.id,
    );
  }

  void setSelectedChannel(Channel channel) {
    final clickOnSelectedChannel = state.listChannels
        .any((e) => e.state == SelectState.SELECTED && e.element.id == channel.id);
    if (clickOnSelectedChannel)
      return;

    // Update selection state on UI
    final updateList = state.listChannels.map((c) {
      return c.element.id == channel.id
          ? SelectableItem(c.element, SelectState.SELECTED)
          : SelectableItem(c.element, SelectState.NONE);
    }).toList();
    emit(state.copyWith(newListChannels: updateList));
  }

  dynamic getCurrentSelectedResource({required ResourceKind kind}) {
    switch (kind) {
      case ResourceKind.Company:
        return state.listCompanies
            .firstWhere((element) => element.state == SelectState.SELECTED)
            .element;
      case ResourceKind.Workspace:
        return state.listWorkspaces
            .firstWhere((element) => element.state == SelectState.SELECTED)
            .element;
      case ResourceKind.Channel:
        return state.listChannels
            .firstWhere((element) => element.state == SelectState.SELECTED)
            .element;
    }
  }

  void updateStartUploadingStatus() {
    emit(state.copyWith(newStatus: ReceiveShareFileStatus.uploadingFiles));
  }

  void updateFinishedUploadingStatus() {
    emit(state.copyWith(newStatus: ReceiveShareFileStatus.uploadFilesSuccessful));
  }

  void updateNewLimitSize({
    required ResourceKind kind,
    required int newLimitSize,
    required int updatedIndex,
  }) {
    // 1. swap selected item (over limited - 8) with new extended position - 9
    // 2. set new size for horizontal list on main screen
    switch (kind) {
      case ResourceKind.Company:
        final comList = state.listCompanies;
        final removedItem = comList.removeAt(updatedIndex);
        comList.insert(limitItems, removedItem);
        emit(state.copyWith(newLimitCompanyList: newLimitSize, newListCompanies: comList));
        break;
      case ResourceKind.Workspace:
        final wsList = state.listWorkspaces;
        final removedItem = wsList.removeAt(updatedIndex);
        wsList.insert(limitItems, removedItem);
        emit(state.copyWith(newLimitWorkspaceList: newLimitSize, newListWorkspaces: wsList));
        break;
      case ResourceKind.Channel:
        final channelList = state.listChannels;
        final removedItem = channelList.removeAt(updatedIndex);
        channelList.insert(limitItems, removedItem);
        emit(state.copyWith(newLimitChannelList: newLimitSize, newListChannels: channelList));
        break;
    }
  }

  void resetStateData() {
    emit(state.copyWith(
      newStatus: ReceiveShareFileStatus.init,
      newLimitCompanyList: limitItems,
      newLimitWorkspaceList: limitItems,
      newLimitChannelList: limitItems,
    ));
  }
}

enum ResourceKind {
  Company,
  Workspace,
  Channel
}
