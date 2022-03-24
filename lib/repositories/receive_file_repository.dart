import 'package:twake/models/receive_sharing/shared_location.dart';
import 'package:twake/services/service_bundle.dart';

class ReceiveFileRepository {

  final _storage = StorageService.instance;

  ReceiveFileRepository();

  Future<SharedLocation?> fetchLastSharedLocation() async {
    final localResult = await _storage.select(
      table: Table.sharedLocation,
      orderBy: 'id DESC',
      limit: 1,
    );
    if(localResult.isEmpty)
      return null;
    var locations = localResult.map((entry) => SharedLocation.fromJson(json: entry)).toList();
    return locations.first;
  }

  Future<void> saveSharedLocation({required SharedLocation location}) async {
    await _storage.insert(table: Table.sharedLocation, data: location);
  }
}