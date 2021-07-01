import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';

class PullToRefreshHeader extends RefreshIndicator {
  @override
  State<StatefulWidget> createState() {
    return PullToRefreshHeaderState();
  }
}

class PullToRefreshHeaderState
    extends RefreshIndicatorState<PullToRefreshHeader> {
  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    return Align(
      alignment: Alignment.center,
      child: TwakeCircularProgressIndicator(
        width: 25.0,
        height: 25.0,
      ),
    );
  }
}
