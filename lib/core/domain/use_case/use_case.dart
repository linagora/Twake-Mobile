import 'package:dartz/dartz.dart';
import 'package:twake/core/domain/state/failure.dart';

abstract class UseCase<Input extends UseCaseInput, Success> {
  Either<ExceptionFailure, Success> execute({required Input input});
}

abstract class NonInputUseCase<Success> {
  Either<ExceptionFailure, Success> execute();
}

abstract class UseCaseInput {}
