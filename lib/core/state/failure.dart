import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {}

abstract class FeatureFailure extends Failure {}

class ExceptionFailure extends Failure {
  final dynamic exception;

  ExceptionFailure(this.exception);

  @override
  List<Object?> get props => [
        exception,
      ];
}
