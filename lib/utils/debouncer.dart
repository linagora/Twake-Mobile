import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  final int delay;
  Timer? _timer;

  Debouncer({required this.delay});

  run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delay), callback);
  }
}
