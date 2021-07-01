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
    extends RefreshIndicatorState<PullToRefreshHeader>
    with TickerProviderStateMixin {
  Tween<Offset> offsetTween = Tween(
    end: Offset(0.6, 0.0),
    begin: Offset(0.0, 0.0),
  );
  late AnimationController _scaleAnimation;
  late AnimationController _offsetController;

  @override
  void initState() {
    _scaleAnimation = _offsetController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    offsetTween = Tween(end: Offset(0.6, 0.0), begin: Offset(0.0, 0.0));
    super.initState();
  }

  @override
  void onOffsetChange(double offset) {
    if (!floating) {
      _scaleAnimation.value = offset / 80.0;
    }
    super.onOffsetChange(offset);
  }

  @override
  void resetValue() {
    _scaleAnimation.value = 0.0;
    _offsetController.value = 0.0;
  }

  @override
  void dispose() {
    _scaleAnimation.dispose();
    _offsetController.dispose();
    super.dispose();
  }

  @override
  Future<void> endRefresh() {
    return _offsetController.animateTo(1.0).whenComplete(() {});
  }

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
