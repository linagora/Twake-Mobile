import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/badges_cubit/badges_state.dart';
import 'package:twake/repositories/badges_repository.dart';
import 'package:twake/services/service_bundle.dart';

class BadgesCubit extends Cubit<BadgesState> {
  late final BadgesRepository _repository;

  BadgesCubit({BadgesRepository? repository}) : super(BadgesInitial()) {
    if (repository == null) {
      repository = BadgesRepository();
    }
    _repository = repository;

    listenToBadgeChanges();
  }

  Future<void> fetch() async {
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
    final badgeUpdateStream =
        SynchronizationService.instance.sockeIOBadgesUpdateStream;

    // ignore the contents, just request all the updates
    await for (final _ in badgeUpdateStream) {
      final badges = await _repository.fetchRemote();

      emit(BadgesLoadSuccess(
        badges: badges,
        hash: badges.fold(0, (acc, b) => b.hash + acc),
      ));
    }
  }
}
