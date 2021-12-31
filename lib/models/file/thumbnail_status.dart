import 'package:json_annotation/json_annotation.dart';

enum ThumbnailStatus {
  @JsonValue('done')
  done,
  @JsonValue('waiting')
  waiting
}