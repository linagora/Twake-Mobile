import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/member_management_cubit/member_management_state.dart';

class MemberManagementCubit extends Cubit<MemberManagementState> {
  MemberManagementCubit() : super(MemberManagementInitial());

}
