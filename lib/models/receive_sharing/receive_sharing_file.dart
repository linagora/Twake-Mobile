import 'package:equatable/equatable.dart';

class ReceiveSharingFile extends Equatable {
  final String name;
  final String path;
  final int size;

  ReceiveSharingFile(this.name, this.path, this.size);

  @override
  List<Object?> get props => [name, path, size];
}
