import 'package:equatable/equatable.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ReceiveSharingFile extends Equatable {
  final String name;
  final String parentPath;
  final int size;
  final SharedMediaType type;

  ReceiveSharingFile(this.name, this.parentPath, this.size, this.type);

  @override
  List<Object> get props => [name, parentPath, size, type];
}
