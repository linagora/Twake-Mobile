import 'package:twake/services/service_bundle.dart';

class RegistrationRepository {
  final _api = ApiService.instance;

  RegistrationRepository();

  Future<String> get secretToken async {
    final String token = '';
    return token;
  }
}
