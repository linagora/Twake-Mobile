import 'dart:math';

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
    bool createAccountOnly = false
  }) async {
    try {
      final prefix = email.split('@').first;
      final name = prefix[0].toUpperCase() + prefix.substring(1);
      await _api.post(
        endpoint: Endpoint.signup,
        data: {
          'email': email,
          'name': name,
          'companyName': 'My company',
          'password': _pass,
          'locale': 'en',
          'secretToken': secretToken,
          'captchaResponseToken': code
        },
        queryParameters: {'createAccountOnly': createAccountOnly},
        key: 'email',
      );
    } on DioError catch (e) {
      Logger().e('Error signing up the user: $e');
      if (e.response?.statusCode == 409) {
        // email exists
        return SignUpStatus.emailExists;
      } else {
        return SignUpStatus.unknownError;
      }
    }
    return SignUpStatus.success;
  }

  Future<bool> resendEmail({required String email}) async {
    try {
      await _api.post(endpoint: Endpoint.emailResend, data: {'email': email});
    } catch (e) {
      Logger().e('Error resending email: $e');
      return false;
    }

    return true;
  }

  String get _pass {
    final generator = Random.secure();
    List<int> pass = [];
    pass.add(generator.nextInt(26) + 65);
    pass.add(generator.nextInt(26) + 97);
    pass.add(generator.nextInt(10) + 48);
    pass.add(generator.nextInt(6) + 59);

    final cycles = generator.nextInt(10) + 10;

    for (int i = 0; i < cycles; i++) {
      pass.add(generator.nextInt(26) + (i % 2 == 0 ? 97 : 65));
    }
    final len = pass.length;
    for (int i = 0; i < len; i++) {
      final to = generator.nextInt(len);
      final from = generator.nextInt(len) + 1;
      final t = pass[to];
      pass[to] = pass[len - from];
      pass[len - from] = t;
    }

    return String.fromCharCodes(pass);
  }
}

enum SignUpStatus { success, emailExists, unknownError }
