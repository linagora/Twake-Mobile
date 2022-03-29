import 'package:equatable/equatable.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/common/selectable_item.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';
import 'package:twake/models/receive_sharing/receive_sharing_text.dart';
import 'package:twake/models/receive_sharing/receive_sharing_type.dart';
import 'package:twake/models/workspace/workspace.dart';

enum ReceiveShareFileStatus {
  init,
  uploadingFiles,
  uploadFilesSuccessful,
  sendingMessage,
  sentMessageSuccessful
}

const int limitItems = 8;

class ReceiveShareFileState extends Equatable {
  final ReceiveShareFileStatus status;
  final ReceiveSharingType sharingType;
  final List<ReceiveSharingFile> listFiles;
  final ReceiveSharingText receivedText;
  final List<SelectableItem<Company>> listCompanies;
  final List<SelectableItem<Workspace>> listWorkspaces;
  final List<SelectableItem<Channel>> listChannels;
  final int limitCompanyList;
  final int limitWorkspaceList;
  final int limitChannelList;

  const ReceiveShareFileState({
    this.status = ReceiveShareFileStatus.init,
    this.sharingType = ReceiveSharingType.None,
    this.listFiles = const [],
    this.receivedText = const ReceiveSharingText.initial(),
    this.listCompanies = const [],
    this.listWorkspaces = const [],
    this.listChannels = const [],
    this.limitCompanyList = limitItems,
    this.limitWorkspaceList = limitItems,
    this.limitChannelList = limitItems,
  });

  ReceiveShareFileState copyWith({
    ReceiveShareFileStatus? newStatus,
    ReceiveSharingType? newSharingType,
    List<ReceiveSharingFile>? newListFiles,
    ReceiveSharingText? newText,
    List<SelectableItem<Company>>? newListCompanies,
    List<SelectableItem<Workspace>>? newListWorkspaces,
    List<SelectableItem<Channel>>? newListChannels,
    int? newLimitCompanyList,
    int? newLimitWorkspaceList,
    int? newLimitChannelList,
  }) {
    return ReceiveShareFileState(
      status: newStatus ?? this.status,
      sharingType: newSharingType ?? this.sharingType,
      listFiles: newListFiles ?? this.listFiles,
      receivedText: newText ?? this.receivedText,
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
        sharingType,
        listFiles,
        receivedText,
        listCompanies,
        listWorkspaces,
        listChannels,
        limitCompanyList,
        limitWorkspaceList,
        limitChannelList,
      ];
}
