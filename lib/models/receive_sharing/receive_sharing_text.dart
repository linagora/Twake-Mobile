import 'package:equatable/equatable.dart';

class ReceiveSharingText extends Equatable {
  final String text;

  const ReceiveSharingText(this.text);

  const ReceiveSharingText.initial() : this('');

  @override
  List<Object> get props => [text];
}
