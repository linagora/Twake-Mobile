import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:twake/blocs/member_cubit/member_state.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/models/member.dart';

class MemberCubit extends Cubit<MemberState> {
  final CollectionRepository<Member> repository;

  MemberCubit(this.repository) : super(MemberInitial());

  Future<void> fetchMembers({@required String channelId}) async {
    await repository.reload();
    emit(MembersLoaded(members: repository.items));
  }

  void updateMembers({
    @required String channelId,
    @required List<Member> members,
  }) {

  }
}
