class Endpoint {
  /// List of public methods

  // API Endpoint for getting API version info + auth method
  static const info = '/internal/services/general/v1/server';
  // API Endpoint for authentication
  static const authorize = '/authorize';
  // API Endpoint for prolonging token
  static const authorizationProlong = '/authorization/prolong';

  /// List of internal methods, for authorized users only

  // API Endpoint for sending logout event to backend
  static const logout = '/logout';
  // API Endpoint for working with account data
  static const account = '/user';
  // API Endpoint for working with user's companies
  static const companies = '/internal/services/users/v1/users/%s/companies';
  // API Endpoint for working with user's companies
  static const badges = '/badges';
  // API Endpoint for working with user's workspaces in all companies
  static const workspaces =
      '/internal/services/users/v1/companies/%s/workspaces';
  // API Endpoint for working with the members of workspace
  static const workspaceMembers = '/workspaces/members';
  // API Endpoint for working with user's channels in a workspace
  static const channels = '/channels';
  // API Endpoint for marking the channel as read
  static const channelsRead = '/channels/read';
  // API Endpoint for working with the members of user's channels
  static const channelMembers = '/channels/members';
  // API Endpoint for working with user's direct channels with other users
  static const directs = '/direct';
  // API Endpoint for working with messages in a channel
  static const messages = '/messages';
  // API Endpoint for working with message reactions
  static const reactions = '/reactions';
  // API Endpoint for getting all the rooms to which it's possible to subscribe
  static const notificationRooms = '/workspace/notifications';
  // API Endpoint for getting all the rooms to which it's possible to subscribe
  static const fileUpload = '/media/upload';

  // Core methods
  // Obtain JWToken pair for Twake
  static const token = '/ajax/users/console/token';

  static const proxyMethods = const [
    account,
    badges,
    workspaceMembers,
    channels,
    channelsRead,
    channelMembers,
    directs,
    messages,
    reactions,
    notificationRooms,
    fileUpload,
    logout,
    authorize,
    authorizationProlong,
  ];

  static const publicMethods = const [
    authorize,
    authorizationProlong,
    info,
    token,
  ];
  // Returns true if the method is publicly accessable, i.e. without authorization
  static bool isPublic(String method) {
    return publicMethods.contains(method);
  }

  static bool isProxy(String method) {
    return proxyMethods.contains(method);
  }
}
