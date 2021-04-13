// Colors to use in CircleAvatar with the user's initials.

import 'dart:math';
import 'dart:ui';

const Color one = Color(0xff6E44FF);
const Color two = Color(0xff00B283);
const Color three = Color(0xffF45B69);
const Color four = Color(0xffFFD166);
const List<Color> hexColor = [one, two, three, four];

Color randomColor() {
  final random = Random();
  return hexColor[random.nextInt(hexColor.length)];
}