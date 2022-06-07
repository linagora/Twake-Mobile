import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class LocalFile extends Equatable {
  final String name;
  final int size;
  final String? path;
  final int? updatedAt;
  final Uint8List? thumbnail;

  LocalFile(
      {required this.name,
      required this.size,
      this.path,
      this.updatedAt,
      this.thumbnail});

  LocalFile copyWith(
      {String? name,
      int? size,
      String? path,
      int? updatedAt,
      Uint8List? thumbnail}) {
    return LocalFile(
        name: name ?? this.name,
        size: size ?? this.size,
        path: path ?? this.path,
        thumbnail: thumbnail ?? this.thumbnail,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  String? get extension => name.split('.').last;

  get isImageFile =>
      {'png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'bmp'}.contains(extension);

  @override
  List<Object?> get props => [name, path, size, updatedAt];
}
