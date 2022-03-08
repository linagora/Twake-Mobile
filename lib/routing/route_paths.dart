class RoutePaths {
  static const initial = '/initial/';

  // channel
  static final channelMessages = _RoutePathsType(initial, '/channel/messages');
  static final channelDetail =
      _RoutePathsType(channelMessages.path, '/channel_detail');
  static final editChannel =
      _RoutePathsType(channelDetail.path, '/edit_channel');
  static final channelSettings =
      _RoutePathsType(channelDetail.path, '/channel_settings');
  static final channelMemberManagement =
      _RoutePathsType(channelDetail.path, '/channel_member_management');
  static final addChannelMembers =
      _RoutePathsType(channelMemberManagement.path, '/add_channel_members');
  static final newDirect = _RoutePathsType(initial, '/channel/new_direct');
  static final newChannel = _RoutePathsType(newDirect.path, '/new_channel');
  static final addAndEditChannelMembers =
      _RoutePathsType(newChannel.path, '/add_and_edit_channel_members');
  static final addAndEditDirectMembers =
      _RoutePathsType(newDirect.path, '/add_and_edit_channel_members');

  // direct
  static final directMessages = _RoutePathsType(initial, '/direct/messages');

  // threads
  static final channelMessageThread =
      _RoutePathsType(initial, '/channel/message/thread');
  static final directMessageThread =
      _RoutePathsType(initial, '/direct/message/thread');

  // account
  static final accountSettings = _RoutePathsType(initial, '/account_settings');
  static final accountInfo =
      _RoutePathsType(initial, '/account_settings/account_info');
  static final accountLanguage =
      _RoutePathsType(accountSettings.path, '/select_language');
  static final accountTheme =
      _RoutePathsType(accountSettings.path, '/select_theme');

  static final createWorkspace = _RoutePathsType(initial, '/create_workspace');
  static final homeWidget = _RoutePathsType(initial, '/homeWidget');

  // initial
  static final signInUpScreen = _RoutePathsType(initial, '/sign_flow');

  // magic link
  static final invitationPeople =
      _RoutePathsType(initial, '/invitation_people');
  static final invitationPeopleEmail =
      _RoutePathsType(invitationPeople.path, '/invitation_people_email');
  static final joinWorkspaceByMagicLink =
      _RoutePathsType(initial, '/join_workspace_by_magic_link');

  // file
  static final channelFilePreview =
      _RoutePathsType(initial, '/channel_file_preview');
  static final directFilePreview =
      _RoutePathsType(initial, '/direct_file_preview');

  // receive sharing file
  static final shareFile = _RoutePathsType(homeWidget.path, '/share_file');
  static final shareFileList =
      _RoutePathsType(shareFile.path, '/share_file_list');
  static final shareFileCompList =
      _RoutePathsType(shareFile.path, '/share_file_comp_list');
  static final shareFileWsList =
      _RoutePathsType(shareFile.path, '/share_file_ws_list');
  static final shareFileChannelList =
      _RoutePathsType(shareFile.path, '/share_file_channel_list');
}

class _RoutePathsType {
  final String _name;
  final String _rootPath;

  _RoutePathsType(this._rootPath, this._name);

  String get name => _name;

  String get path => _rootPath + name;
}
