import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:twake/blocs/mentions_cubit/mentions_state.dart';
import 'package:twake/repositories/mentions_repository.dart';

export 'package:twake/blocs/mentions_cubit/mentions_state.dart';

class MentionsCubit extends Cubit<MentionState> {
  final MentionsRepository repository = MentionsRepository();
  final _userMentionRegex = RegExp(r'(^|\s)@[A-Za-z1-9_-]+(\s|$)');

  MentionsCubit() : super(MentionsEmpty());

  Future<void> fetchMentionableUsers({required String searchTerm}) async {
    final users = await repository.mentionableUsers(searchTerm);
    if (users.isNotEmpty) {
      emit(MentionableUsersLoaded(users: users));
    } else {
      emit(MentionsEmpty());
    }
  }

  void clearMentions() {
    emit(MentionsEmpty());
  }

  Future<String> completeMentions(String text) async {
    final matches = _userMentionRegex.allMatches(text);
    String completeText = '' + text; // create a copy

    for (var m in matches) {
      final username =
          text.substring(m.start, m.end).split('@').last.trimRight();
      final userId = await repository.getUserId(username);
      completeText = completeText.replaceAll(username, '$username:$userId');
    }

    return completeText;
  }
}
