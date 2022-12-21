import 'dart:math';

import 'package:flutter/widgets.dart';

// Size of the block used in determining multipliers
const double _BLOCK_SIZE_VERT = 100;
const double _BLOCK_SIZE_HORZ = 100;

// Multiplier for icons used in buttons
// const double ICON_SIZE_MULTIPLIER = 4.5;

/// Configuration of screen dimensions, should be initialized
/// from the root of the application, when it's run.
class Dim {
  static double? _screenWidth;
  static double? _screenHeight;
  static bool isPortrait = true;
  // static bool isMobilePortrait = false;

  /// Initialization method to setup all the neccessary constants
  /// Must be called in the root widget tree
  static void init(BoxConstraints constraints, Orientation orientation) {
    if (orientation == Orientation.portrait) {
      _screenWidth = constraints.maxWidth;
      _screenHeight = constraints.maxHeight;
      isPortrait = true;
    } else {
      _screenWidth = constraints.maxHeight;
      _screenHeight = constraints.maxWidth;
      isPortrait = false;
    }

    // Calculating number of blocks, in order to determine values
    // of scaling multipliers
    _blockWidth = _screenWidth! / _BLOCK_SIZE_HORZ;
    _blockHeight = _screenHeight! / _BLOCK_SIZE_VERT;
  }

  // Number of blocks, of width _BLOCK_SIZE_XXX, which can fit
  // into span of available space on screen
  static double _blockWidth = 0;
  static double _blockHeight = 0;

  /// Multiplier applied to fontSize attribute of text based widgets
  /// Must be accessed only after init
  static double get textMultiplier {
    return sqrt(_blockHeight * _blockWidth) * 1.3;
  }

  /// Multiplier, which can be applied to radius or width/height
  /// attribute of image containing widgets
  /// Must be accessed only after init
  static double get imageSizeMultiplier {
    return _blockWidth;
  }

  /// Multiplier used anywhere, if there's a need to scale widget,
  /// taking height of the screen into account
  /// Must be accessed only after init
  static double get heightMultiplier {
    return _blockHeight;
  }

  /// Multiplier used anywhere, if there's a need to scale widget,
  /// taking width of the screen into account
  /// Must be accessed only after init
  static double get widthMultiplier {
    return _blockWidth;
  }

  /// Available screen height
  /// Must be accessed only after init
  static double? get maxScreenHeight {
    return isPortrait ? _screenHeight : _screenWidth;
  }

  /// Available screen width
  /// Must be accessed only after init
  static double? get maxScreenWidth {
    return isPortrait ? _screenWidth : _screenHeight;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm2 {
    return _blockWidth * 2;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm3 {
    return _blockWidth * 3;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm4 {
    return _blockWidth * 4;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm5 {
    return _blockWidth * 5;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm6 {
    return _blockWidth * 6;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm7 {
    return _blockWidth * 7;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm8 {
    return _blockWidth * 8;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm9 {
    return _blockWidth * 9;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm10 {
    return _blockWidth * 10;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm11 {
    return _blockWidth * 11;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get wm30 {
    return _blockWidth * 30;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get hm2 {
    return _blockHeight * 2;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get hm3 {
    return _blockHeight * 3;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get hm4 {
    return _blockHeight * 4;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get hm5 {
    return _blockHeight * 5;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get hm6 {
    return _blockHeight * 6;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get hm7 {
    return _blockHeight * 7;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get hm8 {
    return _blockHeight * 8;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get hm9 {
    return _blockHeight * 9;
  }

  /// Convenience method for getting multiple of width multiplier
  static double get hm10 {
    return _blockHeight * 10;
  }

  /// Convenience method for getting multiple of text multiplier
  /// [decimal] parameter is there for adjustments and should not exceed 1
  static double tm2({double decimal: 0}) {
    return textMultiplier * (2 + decimal);
  }

  /// Convenience method for getting multiple of text multiplierfi;
  /// [decimal] parameter is there for adjustments and should not exceed 1
  static double tm3({double decimal: 0}) {
    return textMultiplier * (3 + decimal);
  }

  /// Convenience method for getting multiple of text multiplier
  /// [decimal] parameter is there for adjustments and should not exceed 1
  static double tm4({double decimal: 0}) {
    return textMultiplier * (4 + decimal);
  }

  /// Convenience method for getting multiple of text multiplier
  /// [decimal] parameter is there for adjustments and should not exceed 1
  static double tm5({double decimal: 0}) {
    return textMultiplier * (5 + decimal);
  }

  /// Convenience method for getting percentage of available screen width
  /// [percent] must be a number between 1 and 100 (exclusive)
  static double widthPercent(int percent) {
    assert(percent > 0 && percent < 100);
    return _blockWidth * percent;
  }

  /// Convenience method for getting percentage of available screen height
  /// [percent] must be a number between 1 and 100 (exclusive)
  static double heightPercent(int percent) {
    // assert(percent > 0 && percent < 100);
    return _blockHeight * percent;
  }
}
