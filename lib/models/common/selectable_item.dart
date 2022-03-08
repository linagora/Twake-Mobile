import 'package:equatable/equatable.dart';

enum SelectState { NONE, SELECTED }

class SelectableItem<T> extends Equatable {
  final T element;
  final SelectState state;

  SelectableItem(this.element, this.state);

  @override
  List<Object?> get props => [element, state];
}
