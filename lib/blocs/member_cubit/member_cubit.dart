import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:twake/blocs/member_cubit/member_state.dart';
import 'package:twake/repositories/member_repository.dart';

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
    final updatedMembers = await repository.updateMembers(
      members: members,
      channelId: channelId,
    );
    if (updatedMembers.length > 0) {
      emit(MembersUpdated(channelId: channelId, members: updatedMembers));
    } else {
      emit(MembersError('Error during members update.'));
    }
  }
}
