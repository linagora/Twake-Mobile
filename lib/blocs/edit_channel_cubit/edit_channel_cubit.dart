import 'package:bloc/bloc.dart';
import 'edit_channel_state.dart';

class EditChannelCubit extends Cubit<EditChannelState> {
  EditChannelCubit() : super(EditChannelInitial());
}
