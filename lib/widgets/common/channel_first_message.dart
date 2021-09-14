import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/utils/emojis.dart';

import 'image_widget.dart';

class ChannelFirstMessage extends StatelessWidget {
  final String icon;
  final Channel channel;
  const ChannelFirstMessage({required this.channel, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          channel.isDirect
              ? icon == ""
                  ? Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 2,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Image.asset('assets/images/3.0x/rocket.png'))
                  : ImageWidget(
                      imageType: ImageType.common,
                      imageUrl: icon,
                      size: 120,
                    )
              : channel.icon == ""
                  ? Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        border: Border.all(
                          style: BorderStyle.solid,
                          width: 2,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Image.asset('assets/images/3.0x/rocket.png'))
                  : ImageWidget(
                      imageType: ImageType.channel,
                      imageUrl: Emojis.getByName(channel.icon ?? ""),
                      size: 120,
                    ),
          SizedBox(
            height: 25,
          ),
          Text(
            '${channel.name}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w800,
              color: Color(0xff444444),
            ),
          ),
          Container(
            width: 150,
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            child: Text(
              AppLocalizations.of(context)!.firstMessageInChannelInfo,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
