/// Abstract class, used to hold all the common behavior,
/// which should be shared across the models
abstract class BaseModel {
  const BaseModel();

  Map<String, dynamic> toJson({bool stringify: true});
}
