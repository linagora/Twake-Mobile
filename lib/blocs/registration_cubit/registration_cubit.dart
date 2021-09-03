import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twake/blocs/registration_cubit/registration_state.dart';
import 'package:twake/repositories/registration_repository.dart';

export 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  late final RegistrationRepository _repository;

  RegistrationCubit({RegistrationRepository? repository})
      : super(RegistrationInitial()) {
    if (repository == null) {
      repository = RegistrationRepository();
    }
    _repository = repository;
  }

  void prepare() async {
    final secretToken = await _repository.secretToken;

    emit(RegistrationReady(
      secretToken: secretToken,
      code: dotenv.env['CAPTCHA_TOKEN']!,
    ));
  }

  Future<void> signup({
    required String email,
    required String secretToken,
    required String code,
  }) async {
    final status = await _repository.signup(
      email: email,
      secretToken: secretToken,
      code: code,
    );

    switch (status) {
      case SignUpStatus.success:
        emit(RegistrationSuccess(email: email));
        break;
      case SignUpStatus.emailExists:
      case SignUpStatus.unknownError:
        emit(RegistrationFailed(
          email: email,
          emailExists: status == SignUpStatus.emailExists,
        ));
    }
  }

  Future<void> resendEmail({required String email}) async {
    final res = await _repository.resendEmail(email: email);

    if (res) {
      emit(EmailResendSuccess());
    } else {
      emit(EmailResendFailed());
    }
  }
}
