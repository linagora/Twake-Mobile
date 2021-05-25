import 'package:bloc/bloc.dart';
import 'mentions_state.dart';
import 'package:twake/repositories/mentions_repository.dart';

export 'mentions_state.dart';

class MentionsCubit extends Cubit<MentionState> {
  late final MentionsRepository _repository;

  MentionsCubit({MentionsRepository? repository}) : super(MentionsInitial()) {
    if (repository == null) {
      repository = MentionsRepository();
    }
    _repository = repository;
  }

  Future<void> fetch({required String searchTerm}) async {
    final accounts =
        await _repository.fetchWorkspaceAccounts(match: searchTerm);

    emit(MentionsLoadSuccess(accounts: accounts));
  }

  void reset() {
    emit(MentionsInitial());
  }

  Future<String> completeMentions(String messageText) async {
    final completeText =
        await _repository.completeMentionsWithIDs(messageText: messageText);

    return completeText;
  }
}
