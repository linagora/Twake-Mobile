import 'dart:ui';
import 'dart:math';
import 'package:twake/models/member.dart';
import 'package:twake/models/user.dart';

extension StringExtension on String {
  bool get isNotReallyEmpty => this.trim().isNotEmpty;

  bool get isReallyEmpty => this.trim().isEmpty;
}

extension MemberExtension on List<Member> {
  List<String> get ids => this.map((e) => e.userId).toList();
}

extension UsersListExtension on List<User> {
  void excludeUsers(List<User> toExclude) {
    for (User user in toExclude) {
      this.removeWhere((element) => element.id == user.id);
    }
  }
}

// Colors to use in CircleAvatar with the user's initials.

const Color one = Color(0xff6E44FF);
const Color two = Color(0xff00B283);
const Color three = Color(0xffF45B69);
const Color four = Color(0xffFFD166);
const List<Color> hexColor = [one, two, three, four];

extension RandomColor on Color {
  Color randomColor() {
    final random = Random();
    return hexColor[random.nextInt(hexColor.length)];
  }
}
