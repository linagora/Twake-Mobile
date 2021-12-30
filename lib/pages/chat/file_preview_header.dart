import 'package:flutter/material.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

class FilePreviewHeader extends StatelessWidget {
  final bool isDirect;
  final String channelIcon;
  final String channelName;
  final List<Avatar> avatars;
  final String fileName;

  const FilePreviewHeader(
      {Key? key,
      required this.isDirect,
      this.channelIcon = '',
      this.channelName = '',
      this.fileName = '',
      this.avatars = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 12.0),
        ImageWidget(
            imageType: isDirect ? ImageType.common : ImageType.channel,
            size: 38,
            imageUrl: isDirect ? avatars.first.link : channelIcon,
            avatars: avatars,
            stackSize: 24,
            name: channelName),
        SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoading(
                key: ValueKey<String>('channelName'),
                isLoading: channelName.isEmpty,
                width: 60.0,
                height: 10.0,
                child: Text(
                  channelName,
                  style: StylesConfig.commonTextStyle.copyWith(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                fileName,
                style: StylesConfig.commonTextStyle.copyWith(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff92929C),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 15),
      ],
    );
  }
}
