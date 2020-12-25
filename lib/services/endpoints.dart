class Endpoint {
  // API Endpoint for authentication
  static const auth = '/authorize';
  // API Endpoint for prolonging token
  static const prolong = '/token/prolong';
  // API Endpoint for getting user data
  static const profile = '/user';
  // API Endpoint for getting user's companies
  static const companies = '/companies';
  // API Endpoint for getting user's workspaces in all companies
  static const workspaces = '/workspaces';
  // API Endpoint for getting user's channels in a workspace
  static const channels = '/channels';
  // API Endpoint for getting user's direct channels with other users
  static const directs = '/direct';
  // API Endpoint for getting messages in a channel
  static const messages = '/messages';
}
