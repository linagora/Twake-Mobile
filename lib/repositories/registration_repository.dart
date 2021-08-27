import 'package:dio/dio.dart';
import 'package:twake/services/service_bundle.dart';

class RegistrationRepository {
  final _api = ApiService.instance;

  RegistrationRepository();

  Future<String> get secretToken async {
    final String token = await _api.post(
      endpoint: Endpoint.reservation,
      data: const {
        'planId': 'free',
        'planQuantity': 0,
      },
      key: 'secretToken',
    );
    return token;
  }

  Future<SignUpStatus> signup({
    required String email,
    required String secretToken,
    required String code,
  }) async {
    try {
      final prefix = email.split('@').first;
      final name = prefix[0].toUpperCase() + prefix.substring(1);
      await _api.post(
        endpoint: Endpoint.signup,
        data: {
          'email': email,
          'name': name,
          'company': 'My company',
        },
        key: 'email',
      );
    } on DioError catch (e) {
      if (e.response?.statusCode == 409) {
        // email exists
        return SignUpStatus.emailExists;
      } else {
        Logger().e('Error signing up the user: $e');
        return SignUpStatus.unknownError;
      }
    }
    return SignUpStatus.success;
  }
}

enum SignUpStatus { success, emailExists, unknownError }
