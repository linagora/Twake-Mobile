import 'package:hive_flutter/hive_flutter.dart';

/// Provides abstract methods that operate with Hive storage directly,
/// it will be represented by Hive data objects only.
abstract class BaseHiveClient<T> {
  String get tableName;

  Future<Box<T>> openBox();

  Future<void> insert(T newObject);

  Future<void> cleanInsert(T newObject);

  Future<void> multiInsert(Iterable<T> mapObject);

  Future<List<T>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  });

  Future<void> updateById({required T object, List<String>? ids});

  Future<void> deleteById({List<String>? ids});

  Future<void> truncate() async {
    await Hive.deleteBoxFromDisk(tableName);
  }

}
