import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/badges_cubit/badges_state.dart';
import 'package:twake/repositories/badges_repository.dart';

class BadgesCubit extends Cubit<BadgesState> {
  late final BadgesRepository _repository;

  BadgesCubit({BadgesRepository? repository}) : super(BadgesInitial()) {
    if (repository == null) {
      repository = BadgesRepository();
    }
    _repository = repository;
  }

  void fetch() async {
    emit(BadgesLoadInProgress());

    final badgesStream = _repository.fetch();

    await for (final badges in badgesStream) {
      emit(BadgesLoadSuccess(
        badges: badges,
        hash: badges.fold(0, (acc, b) => b.hash + acc),
      ));
    }
  }

  Future<void> listenToBadgeChanges() async {
    // TODO implement listener to badge changes
  }
}
