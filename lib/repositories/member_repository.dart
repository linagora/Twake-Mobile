import 'package:meta/meta.dart';
import 'package:logger/logger.dart';
import 'package:twake/models/member.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/storage/storage.dart';

class MemberRepository extends CollectionRepository<Member> {
  List<Member> items;
  final String apiEndpoint;

  MemberRepository({this.items, @required this.apiEndpoint})
      : super(items: items, apiEndpoint: apiEndpoint);

  static final _api = Api();
  static final _storage = Storage();

  static Future<MemberRepository> load(
    String apiEndpoint, {
    Map<String, dynamic> queryParams,
    List<List> filters,
    Map<String, bool> sortFields, // fields to sort by + sort direction
  }) async {
    List<dynamic> itemsList = await _storage.batchLoad(
      type: StorageType.Member,
      filters: filters,
      orderings: sortFields,
    );
    bool saveToStore = false;
    if (itemsList.isEmpty) {
      // Logger().d('Requesting $T items from api...');
      try {
        itemsList = await _api.get(apiEndpoint, params: queryParams);
      } on ApiError catch (error) {
        Logger()
            .d('ERROR WHILE FETCHING MEMBER items FROM API\n${error.message}');
        throw error;
      }
      saveToStore = true;
    }
    final items = itemsList.map((i) => Member.fromJson(i)).toList();
    final collection = MemberRepository(items: items, apiEndpoint: apiEndpoint);
    if (saveToStore) collection.save();
    return collection;
  }
}
