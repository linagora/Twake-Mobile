// Colors to use in CircleAvatar with the user's initials.

import 'dart:math';
import 'package:flutter/material.dart';

const one = Color(0xff6E44FF);
const two = Color(0xff00B283);
const three = Color(0xffF45B69);
const four = Color(0xffFFD166);
const hexColors = [one, two, three, four];

Color randomColor() {
  final random = Random();
  return hexColors[random.nextInt(hexColors.length)];
}

const gOne = [
  Color(0xff2cd8d5),
  Color(0xff6b8dd6),
  Color(0xff8e37d7),
];

const gTwo = [
  Color(0xffb465da),
  Color(0xffcf6cc9),
  Color(0xffee609c),
  Color(0xffee609c),
];

const gThree = [
  Color(0xfffad0c4),
  Color(0xffff9a9e),
];

const gFour = [
  Color(0xfffaaca8),
  Color(0xffddd6f3),
];

const gradientColors = [gOne, gTwo, gThree, gFour];

LinearGradient randomGradient() {
  final random = Random();
  return LinearGradient(
    transform: GradientRotation(2.79253), // 160 degrees
    tileMode: TileMode.repeated,
    colors: gradientColors[random.nextInt(gradientColors.length)],
  );
}
