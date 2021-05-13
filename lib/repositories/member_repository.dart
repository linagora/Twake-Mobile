import 'package:meta/meta.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/models/member.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/storage/storage.dart';
import 'package:twake/utils/extensions.dart';

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

  Future<bool> fetch({
    @required channelId,
  }) async {
    String companyId = ProfileBloc.selectedCompanyId;
    String workspaceId = ProfileBloc.selectedWorkspaceId;
    return super.reload(
      queryParams: {
        'company_id': companyId,
        'workspace_id': workspaceId,
        'channel_id': channelId,
      },
      sortFields: {'channel_id': true},
    );
  }

  Future<List<Member>> addMembers({
    @required List<String> members,
    @required String channelId,
  }) async {
    return process(
      members: members,
      channelId: channelId,
      shouldUpdate: true,
      shouldExcludeOwner: true,
    );
  }

  Future<List<Member>> deleteMembers({
    @required List<String> members,
    @required String channelId,
  }) async {
    return process(
      members: members,
      channelId: channelId,
      shouldUpdate: false,
      shouldExcludeOwner: true,
    );
  }

  Future<bool> deleteYourself({
    @required String channelId,
  }) async {
    final userId = ProfileBloc.userId;

    final result = await process(
      members: [userId],
      channelId: channelId,
      shouldUpdate: false,
      shouldExcludeOwner: false,
    );
    final ids = result.ids;
    return ids.contains(userId);
  }

  Future<List<Member>> process({
    @required List<String> members,
    @required String channelId,
    @required bool shouldUpdate,
    @required bool shouldExcludeOwner,
  }) async {
    String companyId = ProfileBloc.selectedCompanyId;
    String workspaceId = ProfileBloc.selectedWorkspaceId;

    if (shouldExcludeOwner)
      members.remove(ProfileBloc.userId); // Remove author.

    final body = <String, dynamic>{
      'company_id': companyId,
      'workspace_id': workspaceId,
      'channel_id': channelId,
      'members': members,
    };
    List response;
    try {
      if (shouldUpdate) {
        response = (await _api.post(apiEndpoint, body: body));
      } else {
        response = (await _api.delete(apiEndpoint, body: body));
      }
    } catch (error) {
      logger.e('Error while sending members to api\n${error.message}');
      return [];
    }
    logger.d('RESPONSE AFTER SENDING MEMBERS: $response');
    final updatedMembers =
        response.map((json) => Member.fromJson(json)).toList();
    super.items.addAll(updatedMembers);
    super.save();
    return updatedMembers;
  }
}
