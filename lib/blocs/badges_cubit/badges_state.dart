import 'package:equatable/equatable.dart';
import 'package:twake/models/badge/badge.dart';

abstract class BadgesState extends Equatable {
  const BadgesState();
}

class BadgesInitial extends BadgesState {
  const BadgesInitial();

  @override
  List<Object?> get props => [];
}

class BadgesLoadInProgress extends BadgesState {
  const BadgesLoadInProgress();

  @override
  List<Object?> get props => [];
}

class BadgesLoadSuccess extends BadgesState {
  final List<Badge> badges;
  final int hash;

  const BadgesLoadSuccess({
    required this.badges,
    required this.hash,
  });

  @override
  List<Object?> get props => [hash];
}
