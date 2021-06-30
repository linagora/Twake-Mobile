import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/badges_cubit/badges_state.dart';
import 'package:twake/models/globals/globals.dart';
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

  Future<void> reset({required String channelId}) async {
    if (state is! BadgesLoadSuccess) return;

    final badges = (state as BadgesLoadSuccess).badges;

    final channelBadge = badges.firstWhere(
      (b) => b.matches(type: BadgeType.channel, id: channelId),
      orElse: () => Badge(type: BadgeType.none, id: ''),
    );

    if (channelBadge.type == BadgeType.none) return;

    final workspaceBadge = badges.firstWhere(
      (b) => b.matches(
        type: BadgeType.workspace,
        id: Globals.instance.workspaceId!,
      ),
      orElse: () => Badge(type: BadgeType.none, id: ''),
    );

    if (workspaceBadge.type == BadgeType.workspace) {
      workspaceBadge.count -= channelBadge.count;
      _repository.saveOne(badge: workspaceBadge);
    }

    final companyBadge = badges.firstWhere(
      (b) => b.matches(
        type: BadgeType.workspace,
        id: Globals.instance.companyId!,
      ),
      orElse: () => Badge(type: BadgeType.none, id: ''),
    );

    if (companyBadge.type == BadgeType.company) {
      companyBadge.count -= channelBadge.count;
      _repository.saveOne(badge: companyBadge);
    }

    channelBadge.count = 0;
    _repository.saveOne(badge: channelBadge);

    emit(BadgesLoadSuccess(
      badges: badges,
      hash: badges.fold(0, (acc, b) => b.hash + acc),
    ));
  }

  Future<void> listenToBadgeChanges() async {
    final badgeUpdateStream =
        SynchronizationService.instance.sockeIOBadgesUpdateStream;

    // ignore the contents, just request all the updates
    await for (final _ in badgeUpdateStream) {
      final badges = await _repository.fetchRemote();

      Logger().v('BADGES FROM REMOTE: ${badges.map((b) => b.toJson())}');

      emit(BadgesLoadSuccess(
        badges: badges,
        hash: badges.fold(0, (acc, b) => b.hash + acc),
      ));
    }
  }
}
