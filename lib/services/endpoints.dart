class Endpoint {
  // Console methods
  // Obtain secretToken for account registration
  static const reservation =
      'https://subscription.%s/api/subscriptions/reservation';
  static const signup = 'https://account.%s/api/signup';

  static const emailResend =
      'https://account.%s/api/users/resend-verification-email';

  // Core methods
  // Obtain JWToken pair for Twake
  static const login = '/internal/services/console/v1/login';
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
  static const threadMessages =
      '/internal/services/messages/v1/companies/%s/threads/%s/messages';
  // API Endpoint for creating threads
  static const threadsPost =
      '/internal/services/messages/v1/companies/%s/threads';
  // API Endpoint for prolonging token
  static const authorizationProlong = '/internal/services/console/v1/token';
  // API Endpoint for marking the channel as read
  static const channelsRead =
      '/internal/services/channels/v1/companies/%s/workspaces/%s/channels/%s/read';
  // API Endpoint for working with user's companies
  static const badges = '/internal/services/notifications/v1/badges';
  static const files = '/internal/services/files/v1/companies/%s/files';
  static const magicLink = '/internal/services/workspaces/v1/workspaces/%s/users/token';

  static const publicMethods = const [info, reservation, signup, emailResend];

  static const consoleMethods = const [reservation, signup, emailResend];
  // Returns true if the method is publicly accessable, i.e. without authorization
  static bool isPublic(String method) {
    return publicMethods.contains(method);
  }

  static bool isConsole(String method) {
    return consoleMethods.contains(method);
  }
}
