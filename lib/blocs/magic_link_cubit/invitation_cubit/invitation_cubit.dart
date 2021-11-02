import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/models/deeplink/magic_link.dart';
import 'package:twake/repositories/magic_link_repository.dart';
import 'invitation_state.dart';

class InvitationCubit extends Cubit<InvitationState> {

  late final MagicLinkRepository _repository;

  InvitationCubit({MagicLinkRepository? repository}) : super(const InvitationState()) {
    if (repository == null) {
      repository = MagicLinkRepository();
    }
    _repository = repository;
  }

  void generateNewLink() async {
    emit(state.copyWith(newStatus: InvitationStatus.inProcessing));

    // TODO: wait API to complete
    //final magicLink = await _repository.generateNewLink();
    final magicLink = MagicLink(getRandomText());

    if(magicLink.link == null || magicLink.link!.isEmpty) {
      emit(state.copyWith(newStatus: InvitationStatus.generateLinkFail));
    } else {
      emit(state.copyWith(newStatus: InvitationStatus.generateLinkSuccess, newLink: magicLink));
    }
  }

  String getRandomText() {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(15, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

}