class Endpoint {
  // API Endpoint for getting API version info + auth method
  static const version = '/';
  // API Endpoint for sending logout event to backend
  static const logout = '/logout';
  // API Endpoint for authentication
  static const auth = '/authorize';
  // API Endpoint for initializing some server required data
  static const init = '/init';
  // API Endpoint for prolonging token
  static const prolong = '/authorization/prolong';
  // API Endpoint for working with user data
  static const profile = '/user';
  // API Endpoint for working with account data
  static const account = '/users/profile';
  // API Endpoint for for profile picture update
  static const accountPicture = '/users/profile/picture';
  // API Endpoint for working with other users
  static const users = '/users';
  // API Endpoint for working with bots (applications)
  static const applications = '/companies/applications';
  // API Endpoint for working with user's companies
  static const companies = '/companies';
  // API Endpoint for working with user's companies
  static const badges = '/badges';
  // API Endpoint for working with user's workspaces in all companies
  static const workspaces = '/workspaces';
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
  // API Endpoint for getting current supported emojis
  static const emojis = '/info/emoji';
  // API Endpoint for searching users by name
  static const usersSearch = '/users/search';
  // API Endpoint for getting latest updates about messages
  static const whatsNew = '/messages/whatsnew';
  // API Endpoint for getting all the rooms to which it's possible to subscribe
  static const notificationRooms = '/workspace/notifications';
  // API Endpoint for getting all the rooms to which it's possible to subscribe
  static const fileUpload = '/media/upload';
}
