import 'package:connectivity/connectivity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/connection_bloc/connection_event.dart';
import 'package:twake/services/api.dart';
import 'package:twake/blocs/connection_bloc/connection_state.dart';

export 'package:twake/blocs/connection_bloc/connection_event.dart';
export 'package:twake/blocs/connection_bloc/connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  var _subscribtion;
  Api _api = Api();
  ConnectionBloc(ConnectionState initState) : super(initState) {
    _subscribtion = Connectivity().onConnectivityChanged.listen((_) {
      this.add(CheckConnectionState());
    });
    Future.delayed(
        Duration(seconds: 3), () => this.add(CheckConnectionState()));
  }

  @override
  Stream<ConnectionState> mapEventToState(event) async* {
    if (event is NotifyConnectionLost) {
      _api.hasConnection = false;
      yield ConnectionLost(DateTime.now().toString());
    } else if (event is NotifyConnectionWiFi) {
      _api.hasConnection = true;
      yield ConnectionWifi();
    } else if (event is NotifyConnectionCellular) {
      _api.hasConnection = true;
      yield ConnectionCellular();
    } else if (event is CheckConnectionState) {
      final state = await Connectivity().checkConnectivity();
      if (state == ConnectivityResult.none) {
        this.add(NotifyConnectionLost());
      } else if (state == ConnectivityResult.wifi) {
        this.add(NotifyConnectionWiFi());
      } else if (state == ConnectivityResult.mobile) {
        this.add(NotifyConnectionCellular());
      }
    }
  }

  @override
  Future<void> close() {
    _subscribtion.cancel();
    return super.close();
  }
}
