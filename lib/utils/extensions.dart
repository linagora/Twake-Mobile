import 'package:twake/models/member.dart';

extension StringExtension on String {
  bool get isNotReallyEmpty => this.trim().isNotEmpty;
  bool get isReallyEmpty => this.trim().isEmpty;
}

extension MemberExtension on List<Member> {
  List<String> get ids => this.map((e) => e.userId).toList();
}