import 'package:json_annotation/json_annotation.dart';

// Intermediate class, used to store all items by their id in database
class CollectionItem extends JsonSerializable {
  String id;
  bool isSelected;
}
