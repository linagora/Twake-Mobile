import 'package:hive/hive.dart';
import 'package:twake/data/local/base_hive_client.dart';
import 'package:twake/models/company/company_hive.dart';
import 'package:twake/services/storage_service.dart';

class CompanyHiveClient extends BaseHiveClient<CompanyHive> {

  @override
  String get tableName => Table.company.name;

  @override
  Future<Box<CompanyHive>> openBox() {
    return Future.sync(() async {
      final boxExist = await Hive.boxExists(tableName);
      if (boxExist) {
        return Hive.box<CompanyHive>(tableName);
      } else {
        return await Hive.openBox<CompanyHive>(tableName);
      }
    });
  }

  @override
  Future<void> insert(CompanyHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> cleanInsert(CompanyHive newObject) {
    return Future.sync(() async {
      final box = await openBox();
      box.clear();
      await box.put(newObject.id, newObject);
    });
  }

  @override
  Future<void> multiInsert(Iterable<CompanyHive> mapObject) {
    return Future.sync(() async {
      final box = await openBox();
      await box.putAll(Map<String, CompanyHive>.fromIterable(
        mapObject,
        key: (element) => element.id,
        value: (element) => element));
    });
  }

  @override
  Future<List<CompanyHive>> selectById({
    List<String>? ids,
    String? orderBy,
    int? limit,
  }) {
    return Future.sync(() async {
      final box = await openBox();

      List<CompanyHive> filterCompanies = box.values.toList();
      if (ids != null) {
        filterCompanies = box.values.where((company) {
          return ids.contains(company.id);
        }).toList();
      }

      return filterCompanies;
    });
  }

  @override
  Future<void> updateById({
    required CompanyHive object,
    List<String>? ids,
  }) {
    return Future.sync(() async {
      final box = await openBox();
      List<CompanyHive> filterCompanies = box.values.toList();
      if (ids != null) {
        filterCompanies = box.values.where((company) {
          return ids.contains(company.id);
        }).toList();
      }
      filterCompanies.forEach((element) async {
        await box.put(element.id, object);
      });
    });
  }

  @override
  Future<void> deleteById({List<String>? ids}) {
    return Future.sync(() async {
      final box = await openBox();
      List<CompanyHive> filterCompanies = box.values.toList();
      if (ids != null) {
        filterCompanies = box.values.where((company) {
          return ids.contains(company.id);
        }).toList();
      }
      filterCompanies.forEach((element) async {
        await box.delete(element.id);
      });
    });
  }

}