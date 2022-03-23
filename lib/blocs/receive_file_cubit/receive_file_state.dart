import 'package:equatable/equatable.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/common/selectable_item.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';
import 'package:twake/models/workspace/workspace.dart';

enum ReceiveShareFileStatus {
  init,
  uploadingFiles,
  uploadFilesSuccessful
}

const int limitItems = 8;

class ReceiveShareFileState extends Equatable {
  final ReceiveShareFileStatus status;
  final List<ReceiveSharingFile> listFiles;
  final List<SelectableItem<Company>> listCompanies;
  final List<SelectableItem<Workspace>> listWorkspaces;
  final List<SelectableItem<Channel>> listChannels;
  final int limitCompanyList;
  final int limitWorkspaceList;
  final int limitChannelList;

  const ReceiveShareFileState({
    this.status = ReceiveShareFileStatus.init,
    this.listFiles = const [],
    this.listCompanies = const [],
    this.listWorkspaces = const [],
    this.listChannels = const [],
    this.limitCompanyList = limitItems,
    this.limitWorkspaceList = limitItems,
    this.limitChannelList = limitItems,
  });

  ReceiveShareFileState copyWith({
    ReceiveShareFileStatus? newStatus,
    List<ReceiveSharingFile>? newListFiles,
    List<SelectableItem<Company>>? newListCompanies,
    List<SelectableItem<Workspace>>? newListWorkspaces,
    List<SelectableItem<Channel>>? newListChannels,
    int? newLimitCompanyList,
    int? newLimitWorkspaceList,
    int? newLimitChannelList,
  }) {
    return ReceiveShareFileState(
      status: newStatus ?? this.status,
      listFiles: newListFiles ?? this.listFiles,
      listCompanies: newListCompanies ?? this.listCompanies,
      listWorkspaces: newListWorkspaces ?? this.listWorkspaces,
      listChannels: newListChannels ?? this.listChannels,
      limitCompanyList: newLimitCompanyList ?? this.limitCompanyList,
      limitWorkspaceList: newLimitWorkspaceList ?? this.limitWorkspaceList,
      limitChannelList: newLimitChannelList ?? this.limitChannelList,
    );
  }

  @override
  List<Object?> get props => [
        status,
        listFiles,
        listCompanies,
        listWorkspaces,
        listChannels,
        limitCompanyList,
        limitWorkspaceList,
        limitChannelList,
      ];
}
