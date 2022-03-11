import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channel_file_cubit/channel_file_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/blocs/channels_cubit/channel_file_cubit/channel_file_state.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/channel/channel_file.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/widgets/common/file_channel_tile.dart';

class ChannelFilesWidget extends StatefulWidget {
  const ChannelFilesWidget({Key? key}) : super(key: key);

  @override
  _ChannelFilesWidgetState createState() => _ChannelFilesWidgetState();
}

class _ChannelFilesWidgetState extends State<ChannelFilesWidget> {
  late final Channel? _currentChannel;
  final channelFileCubit = Get.find<ChannelFileCubit>();

  @override
  void initState() {
    super.initState();
    _currentChannel = Get.arguments;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(_currentChannel != null) {
        channelFileCubit.loadFilesInChannel(_currentChannel!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildListFiles(),
          ],
        ),
      ),
    );
  }

  _buildHeader() {
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      height: 56,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
                onPressed: () => popBack(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).colorScheme.surface,
                )),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              alignment: Alignment.center,
              width: 170,
              child: AutoSizeText(
                AppLocalizations.of(context)!.files,
                maxLines: 1,
                maxFontSize: 17,
                minFontSize: 12,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(
                    fontWeight: FontWeight.w600, fontSize: 17),
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildListFiles() {
    return BlocBuilder<ChannelFileCubit, ChannelFileState>(
      bloc: channelFileCubit,
      builder: (context, state) {
        if(state.channelFileStatus == ChannelFileStatus.finished) {
          final channels = state.listFiles;
          if(channels.isEmpty) {
            return _buildEmptyNotice();
          }
          return Expanded(
            child: Container(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                shrinkWrap: true,
                itemCount: channels.length,
                separatorBuilder: (BuildContext context, int index) => Padding(
                  padding:  EdgeInsets.only(left: Dim.widthPercent(25), top: 6, bottom: 6),
                  child: Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.3),
                    height: 1,
                  ),
                ),
                itemBuilder: (context, index) {
                  return _buildChannelFileItem(channels[index]);
                },
              ),
            ),
          );
        }
        return Container(
          margin: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            backgroundColor: Theme.of(context).colorScheme.background,
            color: Theme.of(context).colorScheme.surface,
            strokeWidth: 1.0,
          ),
        );
      },
    );
  }

  _buildEmptyNotice() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Text(
        AppLocalizations.of(context)!.noFileInChannel,
        style: Theme.of(context).textTheme.headline1!.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  _buildChannelFileItem(ChannelFile channelFile) {
    return FileChannelTile(
      fileId: channelFile.fileId,
      senderName: channelFile.senderName,
    );
  }
}
