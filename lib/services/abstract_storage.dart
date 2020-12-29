abstract class AbstractStorage {
  Future<void> initDb();
  Future<Map<String, dynamic>> load();
  Future<void> store();
  Future<void> storeList();
  Future<List<Map<String, dynamic>>> loadList();
  Future<void> delete();
  Future<void> drop();
  Future<void> fullDrop();
}
