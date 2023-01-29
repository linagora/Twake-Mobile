import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/core/state/failure.dart';
import 'package:twake/core/state/success.dart';

@immutable
abstract class AppState with EquatableMixin {
  final Either<Failure, Success> viewState;

  AppState(this.viewState);

  @override
  List<Object?> get props => [viewState];
}