class Endpoint {
  /// List of public methods

  // API Endpoint for authentication
  static const authorize = '/authorize';
  // API Endpoint for prolonging token
  static const authorizationProlong = '/authorization/prolong';

  /// List of internal methods, for authorized users only

  // API Endpoint for sending logout event to backend
  static const logout = '/logout';
  // API Endpoint for working with user's companies
  static const badges = '/badges';
  // API Endpoint for marking the channel as read
  static const channelsRead = '/channels/read';
  // API Endpoint for working with message reactions
  static const reactions = '/reactions';
  // API Endpoint for getting all the rooms to which it's possible to subscribe
  static const notificationRooms = '/workspace/notifications';
  // API Endpoint for getting all the rooms to which it's possible to subscribe
  static const fileUpload = '/media/upload';

  // Core methods
  // Obtain JWToken pair for Twake
  static const token = '/ajax/users/console/token';
  // API Endpoint for getting API version info + auth method
  static const info = '/internal/services/general/v1/server';
  // API Endpoint for working with user's workspaces in all companies
  static const workspaces =
      '/internal/services/workspaces/v1/companies/%s/workspaces';
  // API Endpoint for working with account data
  static const account = '/internal/services/users/v1/users/%s';
  // API Endpoint for working with user's companies
  static const companies = '/internal/services/users/v1/users/%s/companies';
  // API Endpoint for registering or unregistering device
  static const device = '/internal/services/users/v1/devices';
  // API Endpoint for working with the members of workspace
  static const workspaceMembers =
      '/internal/services/workspaces/v1/companies/%s/workspaces/%s/users';
  // API Endpoint for working with user's channels in a workspace
  static const channels =
      '/internal/services/channels/v1/companies/%s/workspaces/%s/channels';
  // API Endpoint for working with the members of user's channels
  static const channelMembers =
      '/internal/services/channels/v1/companies/%s/workspaces/%s/channels/%s/members';
  // API Endpoint for working with threads in a channel
  static const threads =
      '/internal/services/messages/v1/companies/%s/workspaces/%s/channels/%s/feed';
  // API Endpoint for working with messages inside threads
  static const threadMessages = '/companies/%s/threads/%s/messages';
  // API Endpoint for creating threads
  static const threadsPost = '/companies/%s/threads';

  static const proxyMethods = const [
    badges,
    channelsRead,
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
