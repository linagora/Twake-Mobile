class RoutePaths {
  static const initial = 'initial/';
  static const channelMessages = _RoutePathsType(initial, 'channel/messages');
  static const newChannel = _RoutePathsType(initial, 'channel/new_channel');
  static const directMessages = _RoutePathsType(initial, 'direct/messages');
  static const messageThread = _RoutePathsType(initial, 'message/thread');
  static const accountSettings = _RoutePathsType(initial, 'account_settings');
  static const accountInfo = _RoutePathsType(initial, 'account_settings/account_info');
}

class _RoutePathsType {
  final String _name;
  final String _rootPath;

  const _RoutePathsType(this._rootPath, this._name);

  String get name => _name;

  String get path => _rootPath + name;
}
