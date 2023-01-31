import 'package:flutter/material.dart';
import 'package:twake/models/globals/globals.dart';

abstract class RepositoryHelper {
  navigatorDatasource({
    VoidCallback? onLocal,
    VoidCallback? onRemote,
  }) {
    if (!Globals.instance.isNetworkConnected) {
      onLocal?.call();
      return;
    }
    onRemote?.call();
  }
}

abstract class Repository with RepositoryHelper {}
