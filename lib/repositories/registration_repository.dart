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
          'captchResponseToken': code,
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
      final index = generator.nextInt(len);
      final t = pass[index];
      pass[index] = pass[len - index - 1];
      pass[len - index - 1] = t;
    }

    return String.fromCharCodes(pass);
  }
}

enum SignUpStatus { success, emailExists, unknownError }
