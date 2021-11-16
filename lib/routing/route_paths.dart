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

  static final createWorkspace = _RoutePathsType(initial, '/create_workspace');
  static final homeWidget = _RoutePathsType(initial, '/homeWidget');

  // initial
  static final signInUpScreen = _RoutePathsType(initial, '/sign_flow');

  // magic link
  static final joinWorkspace = _RoutePathsType(initial, '/join_workspace');
  static final invitationPeople = _RoutePathsType(initial, '/invitation_people');
  static final invitationPeopleEmail = _RoutePathsType(invitationPeople.path, '/invitation_people_email');

}

class _RoutePathsType {
  final String _name;
  final String _rootPath;

  _RoutePathsType(this._rootPath, this._name);

  String get name => _name;

  String get path => _rootPath + name;
}
