import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:twake/blocs/member_cubit/member_state.dart';
import 'package:twake/repositories/member_repository.dart';
import 'package:twake/models/member.dart';
import 'package:twake/utils/extensions.dart';

class MemberCubit extends Cubit<MemberState> {
  final MemberRepository repository;

  MemberCubit(this.repository) : super(MemberInitial());

  Future<void> fetchMembers({@required String channelId}) async {
    await repository.reload();
    emit(MembersLoaded(members: repository.items));
  }

  Future<void> updateMembers({
    @required String channelId,
    @required List<String> members,
  }) async {
    final isUpdated = await repository.updateMembers(
      members: members,
      channelId: channelId,
    );
    if (isUpdated) {
      emit(MembersUpdated(channelId: channelId, members: members));
    } else {
      emit(MembersError('Error during members update.'));
    }
  }
}
