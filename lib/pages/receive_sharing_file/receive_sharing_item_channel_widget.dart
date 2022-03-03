import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/common/selectable_item.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const int MAX_TEXT_LEN = 10;

class ReceiveSharingChannelItemWidget extends StatefulWidget {
  final Channel channel;
  final SelectState channelState;

  const ReceiveSharingChannelItemWidget(
      {Key? key, required this.channel, required this.channelState})
      : super(key: key);

  @override
  State<ReceiveSharingChannelItemWidget> createState() => _ReceiveSharingChannelItemWidgetState();
}

class _ReceiveSharingChannelItemWidgetState extends State<ReceiveSharingChannelItemWidget> {
  final receiveFileCubit = Get.find<ReceiveFileCubit>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => receiveFileCubit.setSelectedChannel(widget.channel),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(const Radius.circular(12.0)),
                    border: widget.channelState == SelectState.SELECTED
                        ? Border.all(color: const Color(0xff007AFF), width: 1.5)
                        : null),
                child: ImageWidget(
                  name: widget.channel.name,
                  imageType: ImageType.common,
                  size: 48.0,
                  imageUrl: widget.channel.icon ?? '',
                ),
              ),
              widget.channelState == SelectState.SELECTED
                  ? Transform(
                      transform: Matrix4.translationValues(4, -4, 0),
                      child: Image.asset(imageSelectedRoundBlue, width: 16.0, height: 16.0))
                  : SizedBox.shrink(),
            ],
          ),
          SizedBox(height: 4.0),
          Text (widget.channel.name.length > MAX_TEXT_LEN
                  ? widget.channel.name.substring(0, MAX_TEXT_LEN)
                  : widget.channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 14)),
          SizedBox(height: 4.0),
          Text (AppLocalizations.of(context)?.membersPlural(widget.channel.stats?.members ?? 0) ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 8)),
        ],
      ),
    );
  }
}
