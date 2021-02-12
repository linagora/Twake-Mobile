import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:twake/blocs/member_cubit/member_state.dart';
import 'package:twake/repositories/member_repository.dart';

class MemberCubit extends Cubit<MemberState> {
  final MemberRepository repository;

  MemberCubit(this.repository) : super(MemberInitial());

  Future<void> fetchMembers({@required String channelId}) async {
    await repository.fetch(channelId: channelId);
    emit(MembersLoaded(channelId: channelId, members: repository.items));
  }

  Future<void> addMembers({
    @required String channelId,
    @required List<String> members,
  }) async {
    final updatedMembers = await repository.addMembers(
      members: members,
      channelId: channelId,
    );
    if (updatedMembers.length > 0) {
      emit(MembersAdded(channelId: channelId, members: updatedMembers));
    } else {
      emit(MembersError('Error during members addition.'));
    }
  }

  Future<void> deleteMembers({
    @required String channelId,
    @required List<String> members,
  }) async {
    final updatedMembers = await repository.deleteMembers(
      members: members,
      channelId: channelId,
    );
    // if (updatedMembers.length > 0) {
      emit(MembersDeleted(channelId: channelId, members: updatedMembers));
    // } else {
    //   emit(MembersError('Error during members deletion.'));
    // }
  }

  Future<void> deleteYourself({
    @required String channelId,
  }) async {
    final success =
        await repository.deleteYourself(channelId: channelId);
    if (success) {
      emit(SelfDeleted(channelId: channelId));
    } else {
      emit(MembersError('Error during user self deletion.'));
    }
  }
}
