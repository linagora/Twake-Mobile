import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twake/blocs/writing_cubit/writing_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatWritingStatus extends StatefulWidget {
  final List<UsersWritingData> usersList;
  final bool isDirect;

  const ChatWritingStatus(
      {Key? key, required this.usersList, required this.isDirect})
      : super(key: key);

  @override
  State<ChatWritingStatus> createState() => _ChatWritingStatusState();
}

class _ChatWritingStatusState extends State<ChatWritingStatus> {
  late Timer timer;
  List<bool> dots = [false, false, false];
  @override
  void initState() {
    _runTimer();
    _changeDotsVal(); // for first run while waiting timer
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.usersList.isNotEmpty
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [_buildDots(context), _buildNames(context)],
          )
        : SizedBox.shrink();
  }

  void _runTimer() {
    timer = Timer.periodic(Duration(milliseconds: 400), (timer) async {
      _changeDotsVal();
    });
  }

  void _changeDotsVal() async {
    for (int i = 0; i < dots.length; i++) {
      if (i > 0) await Future.delayed(Duration(milliseconds: 175));
      if (this.mounted)
        setState(() {
          dots[i] = !dots[i];
        });
    }
  }

  Widget _buildNames(BuildContext context) {
    final int length = widget.usersList.length;
    if (widget.isDirect && length == 1) {
      return SizedBox(
        width: Dim.widthPercent(55),
        height: 16,
        child: Text(AppLocalizations.of(context)!.typingMessage,
            style: Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis),
      );
    }
    return SizedBox(
      height: 16,
      width: Dim.widthPercent(95) - 140,
      child: Row(
        children: [
          ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: length < 2 ? length : 2,
            itemBuilder: (context, index) {
              return Text(
                  '${widget.usersList[index].name}${index == 0 && length > 1 ? ', ' : ''}',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis);
            },
          ),
          if (length > 2)
            Text(
                ' ${AppLocalizations.of(context)!.writingCount((length - 2).toString())}',
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildDots(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, right: 2),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: _buildDot(dots[0]),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: _buildDot(dots[1]),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: _buildDot(dots[2]),
          )
        ],
      ),
    );
  }

  Widget _buildDot(bool falg) {
    return SizedBox(
      width: 10,
      child: AnimatedContainer(
        width: falg ? 6 : 8,
        height: falg ? 6 : 8,
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
        decoration: BoxDecoration(
            color: falg
                ? Theme.of(context).colorScheme.surface.withOpacity(0.7)
                : Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle),
      ),
    );
  }
}
