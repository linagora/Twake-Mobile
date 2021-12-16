import 'package:equatable/equatable.dart';

class LocalFile extends Equatable {
  final String name;
  final int size;
  final String? path;
  final int? updatedAt;

  LocalFile(
      {required this.name, required this.size, this.path, this.updatedAt});

  LocalFile copyWith({String? name, int? size, String? path, int? updatedAt}) {
    return LocalFile(
        name: name ?? this.name,
        size: size ?? this.size,
        path: path ?? this.path,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  String? get extension => name.split('.').last;

  @override
  List<Object?> get props => [name, path, size, updatedAt];
}