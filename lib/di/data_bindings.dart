import 'package:get/get.dart';
import 'package:twake/data/local/account2workspace_hive_client.dart';
import 'package:twake/data/local/account_hive_client.dart';
import 'package:twake/data/local/authentication_hive_client.dart';
import 'package:twake/data/local/badge_hive_client.dart';
import 'package:twake/data/local/channel_hive_client.dart';
import 'package:twake/data/local/company_hive_client.dart';
import 'package:twake/data/local/globals_hive_client.dart';
import 'package:twake/data/local/message_hive_client.dart';
import 'package:twake/data/local/sharedlocation_hive_client.dart';
import 'package:twake/data/local/workspace_hive_client.dart';

class DataBindings implements Bindings {
  @override
  Future<void> dependencies() async {
    Get.put(AccountHiveClient());
    Get.put(AuthenticationHiveClient());
    Get.put(BadgeHiveClient());
    Get.put(Account2WorkspaceHiveClient());
    Get.put(CompanyHiveClient());
    Get.put(WorkspaceHiveClient());
    Get.put(ChannelHiveClient());
    Get.put(MessageHiveClient());
    Get.put(GlobalsHiveClient());
    Get.put(SharedLocationHiveClient());
  }

}