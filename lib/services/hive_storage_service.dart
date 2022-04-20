part of 'storage_service.dart';

class HiveStorageService extends StorageService {
  HiveStorageService._(): super._();

  @override
  Future<void> init() async {
    initHive();
  }

  void initHive() {
    hiveStorage.loadLibrary();
    hiveStorage.HiveStorage().init();
  }

  @override
  Future<void> insert({
    required Table table,
    required BaseModel data,
  }) async {
    hiveStorage.HiveStorage().insert(table: table, data: data);
  }

  @override
  Future<void> cleanInsert({
    required Table table,
    required BaseModel data,
  }) async {
    hiveStorage.HiveStorage().cleanInsert(table: table, data: data);
  }

  @override
  Future<void> multiInsert({
    required Table table,
    required Iterable<BaseModel> data,
  }) async {
    hiveStorage.HiveStorage().multiInsert(table: table, data: data);
  }

  @override
  Future<List<Map<String, Object?>>> select({
    required Table table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    return await hiveStorage.HiveStorage().select(
      table: table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  @override
  Future<Map<String, Object?>> first({
    required Table table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final result = await hiveStorage.HiveStorage().select(
      table: table,
      where: where,
      whereArgs: whereArgs,
    );
    return result.length > 0 ? result[0] : const {};
  }

  @override
  Future<void> update({
    required Table table,
    required Map<String, dynamic> values,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await hiveStorage.HiveStorage().update(
      table: table,
      values: values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<void> delete({
    required Table table,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await hiveStorage.HiveStorage().delete(
      table: table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<List<Map<String, Object?>>> rawSelect({
    required String sql,
    List<dynamic>? args,
  }) async {
    //TODO: platform - specify rawSelect
    return [];
  }

  @override
  Future<void> truncate({required Table table}) async {
    await hiveStorage.HiveStorage().truncate(table: table);
  }

  @override
  Future<void> truncateAll() async {
    await hiveStorage.HiveStorage().truncateAll();
  }
}