class Endpoint {
  // API Endpoint for authentication
  static const auth = '/authorize';
  // API Endpoint for initializing some server required data
  static const init = '/init';
  // API Endpoint for prolonging token
  static const prolong = '/authorization/prolong';
  // API Endpoint for working with user data
  static const profile = '/user';
  // API Endpoint for working with other users
  static const users = '/users';
  // API Endpoint for working with user's companies
  static const companies = '/companies';
  // API Endpoint for working with user's workspaces in all companies
  static const workspaces = '/workspaces';
  // API Endpoint for working with user's channels in a workspace
  static const channels = '/channels';
  // API Endpoint for working with members of user's channels
  static const channelMembers = '/channels/members';
  // API Endpoint for working with user's direct channels with other users
  static const directs = '/direct';
  // API Endpoint for working with messages in a channel
  static const messages = '/messages';
  // API Endpoint for working with message reactions
  static const reactions = '/reactions';
  // API Endpoint for getting current supported emojis
  static const emojis = '/settings/emoji';
  // API Endpoint for searching users by name
  static const usersSearch = '/users/search';
}
