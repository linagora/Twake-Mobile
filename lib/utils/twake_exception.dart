import 'package:twake/blocs/authentication_cubit/sync_data_state.dart';

abstract class TwakeException implements Exception {}

class SyncFailedException extends TwakeException {
  final SyncFailedSource failedSource;

  SyncFailedException({required this.failedSource});

}