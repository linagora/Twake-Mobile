
import 'package:equatable/equatable.dart';

abstract class AppState with EquatableMixin {
  const AppState();
}

class InitAppState extends AppState {
  @override
  List<Object?> get props => [];
}