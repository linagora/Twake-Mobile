
import 'package:twake/models/deeplink/magic_link.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/api_service.dart';
import 'package:twake/services/service_bundle.dart';

class MagicLinkRepository {
  final _api = ApiService.instance;

  MagicLinkRepository();

  Future<MagicLink> generateNewLink() async {
    final result = await _api.get(
      endpoint: sprintf(Endpoint.magicLink, [Globals.instance.workspaceId]),
      key: 'resources',
    );
    return MagicLink.fromJson(result);
  }

}