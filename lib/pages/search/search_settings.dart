class SearchTab {
  final String name;
  final String id;

  SearchTab(this.name, this.id);
}

final searchTabsList = [
  SearchTab('All', 'all'),
  SearchTab('Messages', 'messages'),
  SearchTab('Media', 'media'),
  SearchTab('Files', 'files'),
  SearchTab('Channels', 'channels'),
  //SearchTab('Contacts', 'contacts'),
];

const searchDebounceDelay = 250;
const searchAnimationTransitionDelay = 250;

const displayLimitOfRecentChats = 5;
