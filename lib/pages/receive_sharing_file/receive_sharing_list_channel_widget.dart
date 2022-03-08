import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/common/selectable_item.dart';
import 'package:twake/utils/translit.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

class ReceiveSharingChannelListWidget extends StatefulWidget {
  const ReceiveSharingChannelListWidget({Key? key}) : super(key: key);

  @override
  _ReceiveSharingChannelListWidgetState createState() => _ReceiveSharingChannelListWidgetState();
}

class _ReceiveSharingChannelListWidgetState extends State<ReceiveSharingChannelListWidget> {
  final receiveFileCubit = Get.find<ReceiveFileCubit>();
  final _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [_buildHeader(), _buildSearchBar(), _buildList()],
        ),
      ),
    );
  }

  _buildHeader() {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.secondaryVariant,
          height: 52.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).colorScheme.surface,
                    )),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context)?.channelAndChat ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 0.5,
          color: Theme.of(context).colorScheme.secondaryVariant,
        ),
      ],
    );
  }

  _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: TwakeSearchTextField(
        height: 40,
        controller: _searchController,
        hintText: AppLocalizations.of(context)!.searchChannelAndChat,
        backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
      ),
    );
  }

  _buildList() {
    return BlocBuilder<ReceiveFileCubit, ReceiveShareFileState>(
      bloc: receiveFileCubit,
      builder: (context, state) {
        final channels = searchQuery.isEmpty
            ? state.listChannels
            : state.listChannels.where((channel) {
          return channel.element.name.toLowerCase().contains(searchQuery) ||
              channel.element.name
                  .toLowerCase()
                  .contains(translitCyrillicToLatin(searchQuery)) ||
              (channel.element.description?.toLowerCase().contains(searchQuery) ?? false);
        }).toList();
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: ListView.separated(
              padding: const EdgeInsets.all(6),
              shrinkWrap: true,
              itemCount: channels.length,
              separatorBuilder: (BuildContext context, int index) => SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                final channelState = channels[index].state;
                final channel = channels[index].element;
                return buildChannelItem(channel, channelState);
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildChannelItem(Channel channel, SelectState channelState) {
    return GestureDetector(
      onTap: () => receiveFileCubit.setSelectedChannel(channel),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: channelState == SelectState.SELECTED
                        ? Border.all(color: const Color(0xff007AFF), width: 1.5)
                        : null),
                child: ImageWidget(
                  name: channel.name,
                  imageType: ImageType.common,
                  size: 48.0,
                  imageUrl: channel.icon ?? '',
                ),
              ),
              channelState == SelectState.SELECTED
                  ? Image.asset(imageSelectedRoundBlue, width: 16.0, height: 16.0)
                  : SizedBox.shrink(),
            ],
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 14)),
                Text(AppLocalizations.of(context)?.membersPlural(channel.stats?.members ?? 0) ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 8)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
