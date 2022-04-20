import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';

part 'message_summary_hive.g.dart';

@HiveType(typeId: TypeConstant.MESSAGE_SUMMARY)
class MessageSummaryHive extends HiveObject {
  @HiveField(0)
  final int date;

  @HiveField(1, defaultValue: '0')
  final String sender;

  @HiveField(2, defaultValue: 'Guest')
  final String senderName;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String? text;

  MessageSummaryHive({
    required this.date,
    required this.sender,
    required this.senderName,
    required this.title,
    this.text,
  });

}
