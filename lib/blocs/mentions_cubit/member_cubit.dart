import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:twake/blocs/mentions_cubit/member_state.dart';
import 'package:twake/repositories/mentions_repository.dart';

class MentionsCubit extends Cubit<MentionState> {
  final MentionsRepository repository = MentionsRepository();

  MentionsCubit() : super(MentionsEmpty());

  Future<void> fetchMentionableUsers({@required String searchTerm}) async {
    final users = await repository.mentionableUsers(searchTerm);
    if (users.isNotEmpty) {
      emit(MentionableUsersLoaded(users: users));
    } else {
      emit(MentionsEmpty());
    }
  }
}
