import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class MentionsRepository {
  final _storage = StorageService.instance;
  final _userMentionRegex = RegExp(r'(?<=(^|\s))@[A-Za-z1-9._-]+(?=(\s|$))');

  MentionsRepository();

  Future<List<Account>> fetchWorkspaceAccounts({required String match}) async {
    match = '%$match%'; // SQL LIKE pattern
    final sql = '''
        SELECT a.* FROM ${Table.account.name} AS a JOIN
        ${Table.account2workspace.name} AS a2w ON a.id = a2w.user_id
        WHERE a2w.workspace_id = ? AND (
            a.username LIKE ? OR
            a.firstname LIKE ? OR 
            a.lastname LIKE ? OR
            a.email LIKE ?
        )
    ''';
    final args = [
      Globals.instance.workspaceId,
      match,
      match,
      match,
      match
    ]; // 4 match occurences for 4 LIKEs

    final result = await _storage.rawSelect(sql: sql, args: args);

    return result.map((i) => Account.fromJson(json: i)).toList();
  }

  Future<String> completeMentionsWithIDs({required String messageText}) async {
    final matches = _userMentionRegex.allMatches(messageText);

    final Set<String> usernames = matches.map((m) {
      return messageText.substring(m.start, m.end).split('@').last.trimRight();
    }).toSet();

    final placeholders = usernames.map((_) => '?').join(',');

    final result = await _storage.select(
      table: Table.account,
      where: 'username IN ($placeholders)',
      whereArgs: usernames.toList(),
    );
    final accounts = result.map((i) => Account.fromJson(json: i));

    String completeText = messageText.substring(0); // clone original text

    for (final a in accounts) {
      completeText = completeText.replaceAll(
        a.username,
        '${a.username}:${a.id}',
      );
    }

    return completeText;
  }
}
