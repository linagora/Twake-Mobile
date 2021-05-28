import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/models/globals/globals.dart';

class SynchronizationCubit extends Cubit {
  void subscribe({required String room}) {
    if (Globals.instance.isNetworkConnected) _socketio.subscribe(room: room);
  }

  void unsubscribe({required String room}) {
    if (Globals.instance.isNetworkConnected) _socketio.unsubscribe(room: room);
  }
}
