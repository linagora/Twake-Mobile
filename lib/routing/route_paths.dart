class RoutePaths {
  static const initial = 'initial/';
  
  // channel
  static final channelMessages = _RoutePathsType(initial, 'channel/messages');
  static final newDirect = _RoutePathsType(initial, 'channel/new_direct');
  static final newChannel = _RoutePathsType(newDirect.path, '/new_channel');
  static final addChannelMembers = _RoutePathsType(newChannel.path, '/add_members');

  // direct
  static final directMessages = _RoutePathsType(initial, 'direct/messages');
  static final messageThread = _RoutePathsType(initial, 'message/thread');

  // account
  static final accountSettings = _RoutePathsType(initial, 'account_settings');
  static final accountInfo = _RoutePathsType(initial, 'account_settings/account_info');

  static final createWorkspace = _RoutePathsType(initial, 'create_workspace');
  static final homeWidget = _RoutePathsType(initial, 'homeWidget');
}

class _RoutePathsType {
  final String _name;
  final String _rootPath;

  _RoutePathsType(this._rootPath, this._name);

  String get name => _name;

  String get path => _rootPath + name;
}
