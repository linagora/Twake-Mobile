import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:sprintf/sprintf.dart';
import 'package:twake/blocs/magic_link_cubit/invitation_cubit/invitation_state.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/magic_link_repository.dart';
import 'package:twake/services/endpoints.dart';

class InvitationCubit extends Cubit<InvitationState> {

  late final MagicLinkRepository _repository;

  InvitationCubit({MagicLinkRepository? repository}) : super(const InvitationState()) {
    if (repository == null) {
      repository = MagicLinkRepository();
    }
    _repository = repository;
  }

  void resetState() {
    emit(state.copyWith(newStatus: InvitationStatus.init));
  }

  void generateNewLink() async {
    emit(state.copyWith(newStatus: InvitationStatus.inProcessing));
    try {
      final newToken = await _repository.generateToken();
      if(newToken.token.isEmpty) {
        emit(state.copyWith(newStatus: InvitationStatus.generateLinkFail));
      } else {
        final generatedLink = _invitationLink(newToken.token);
        emit(state.copyWith(newStatus: InvitationStatus.generateLinkSuccess, newLink: generatedLink));
      }
    } catch (e) {
      Logger().e('ERROR during generating magic link:\n$e');
      emit(state.copyWith(newStatus: InvitationStatus.generateLinkFail));
    }
  }

  String _invitationLink(String token) {
    return sprintf(Endpoint.magicLink, [Globals.instance.host, token]);
  }

}