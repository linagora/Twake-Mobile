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
  static const workspaceInviteEmail =
      '/internal/services/workspaces/v1/companies/%s/workspaces/%s/users/invite';
  // API Endpoint for working with account data
  static const account = '/internal/services/users/v1/users/%s';
  static const accountPreferences =
      '/internal/services/users/v1/users/me/preferences';
  // API Endpoint for working with user's companies
  static const companies = '/internal/services/users/v1/users/%s/companies';
  // API Endpoint for registering or unregistering device
  static const device = '/internal/services/users/v1/devices';
  // API Endpoint for working with the members of workspace
  static const workspaceMembers =
      '/internal/services/workspaces/v1/companies/%s/workspaces/%s/users';
  static const notificationsAcknowledge =
      '/internal/services/notifications/v1/badges/:company_id/acknowledge';
  // API Endpoint for working with user's channels in a workspace
  static const channels =
      '/internal/services/channels/v1/companies/%s/workspaces/%s/channels';
  // API Endpoint for working with the members of user's channels
  static const channelMembers =
      '/internal/services/channels/v1/companies/%s/workspaces/%s/channels/%s/members';
  // API Endpoint for working with threads in a channel
  static const threadsChannel =
      '/internal/services/messages/v1/companies/%s/workspaces/%s/channels/%s/feed';
  static const threadsDirect =
      '/internal/services/messages/v1/companies/%s/workspaces/direct/channels/%s/feed';
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

  // API Endpoint for working with file in chat
  static const files = '/internal/services/files/v1/companies/%s/files';
  static const fileMetadata =
      '/internal/services/files/v1/companies/%s/files/%s';

  // API Endpoint for magic links
  static const magicLinkTokens =
      '/internal/services/workspaces/v1/companies/%s/workspaces/%s/users/tokens';
  static const magicLinkDeleteToken =
      '/internal/services/workspaces/v1/companies/%s/workspaces/%s/users/tokens/%s';
  static const magicLinkJoin = '/internal/services/workspaces/v1/join';

  static const magicLink = '%s?join=%s';
  static const consolePage = 'https://console.%s';
  static const downloadFile =
      '%s/internal/services/files/v1/companies/%s/files/%s/download';
  static const downloadFileThumbnail =
      '%s/internal/services/files/v1/companies/%s/files/%s/thumbnails/%s';
  static const httpsScheme = 'https://%s';

  // API Endpoint for company files
  static const companyFiles =
      '/internal/services/messages/v1/companies/%s/files';

  // API Endpoint for search
  static const searchChannels =
      '/internal/services/channels/v1/companies/%s/search';
  static const searchRecentChannels =
      '/internal/services/channels/v1/companies/%s/channels/recent';
  static const searchUsers = '/internal/services/users/v1/users';
  static const searchMessages =
      '/internal/services/messages/v1/companies/%s/search';
  static const searchFiles =
      '/internal/services/messages/v1/companies/%s/files/search';

  static const publicMethods = const [info, reservation, signup, emailResend];

  static const consoleMethods = const [reservation, signup, emailResend];
  // Returns true if the method is publicly accessable, i.e. without authorization
  static bool isPublic(String method) {
    return publicMethods.contains(method);
  }

  static bool isConsole(String method) {
    return consoleMethods.contains(method);
  }

  // Supported hosts
  static const prodHost = 'web.twake.app';
  static const qaHost = 'staging-web.twake.app';
  static const canaryHost = 'canary.twake.app';
  static const supportedHosts = const [prodHost, qaHost, canaryHost];
  static bool inSupportedHosts(String host) {
    return supportedHosts.contains(host);
  }
}
