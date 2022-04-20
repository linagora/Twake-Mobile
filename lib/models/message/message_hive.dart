import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/message/pinned_info_hive.dart';
import 'package:twake/models/message/reaction.dart';

part 'message_hive.g.dart';

@HiveType(typeId: TypeConstant.MESSAGE)
class MessageHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String threadId;

  @HiveField(2)
  final String channelId;

  @HiveField(3)
  final String userId;

  @HiveField(4)
  int createdAt;

  @HiveField(5)
  int updatedAt;

  @HiveField(6, defaultValue: 0)
  int responsesCount;

  @HiveField(7, defaultValue: '')
  String text;

  @HiveField(8)
  List<dynamic> blocks;

  @HiveField(9)
  List<dynamic>? files;

  @HiveField(10)
  MessageSubtype? subtype;

  @HiveField(11, defaultValue: [])
  List<Reaction> reactions;

  @HiveField(12)
  PinnedInfoHive? pinnedInfo;

  @HiveField(13)
  String? username;

  @HiveField(14)
  String? firstName;

  @HiveField(15)
  String? lastName;

  @HiveField(16)
  String? picture;

  @HiveField(17)
  String? draft;

  @HiveField(18, defaultValue: Delivery.delivered)
  Delivery delivery;

  MessageHive({
    required this.id,
    required this.threadId,
    required this.channelId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.responsesCount,
    this.username,
    required this.text,
    required this.blocks,
    required this.reactions,
    required this.files,
    this.delivery: Delivery.delivered,
    this.firstName,
    this.lastName,
    this.picture,
    this.draft,
  });
}
