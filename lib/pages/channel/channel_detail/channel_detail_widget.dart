import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/emojis.dart';
import 'package:twake/widgets/common/image_widget.dart';

class ChannelDetailWidget extends StatelessWidget {
  const ChannelDetailWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                        onPressed: () => popBack(),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).colorScheme.surface,
                        )),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: BlocBuilder<ChannelsCubit, ChannelsState>(
                        bloc: Get.find<ChannelsCubit>(),
                        builder: (ctx, channelState) {
                          Channel? selectedChannel =
                              (channelState is ChannelsLoadedSuccess)
                                  ? channelState.selected
                                  : null;
                          return ImageWidget(
                            imageType: ImageType.channel,
                            isPrivate: selectedChannel != null
                                ? selectedChannel.isPrivate
                                : false,
                            imageUrl: (selectedChannel != null &&
                                    selectedChannel.icon != null)
                                ? Emojis.getByName(selectedChannel.icon ?? '')
                                : '',
                            name: selectedChannel != null
                                ? selectedChannel.name
                                : '',
                            size: 100,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondaryContainer,
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 6),
                child: BlocBuilder<ChannelsCubit, ChannelsState>(
                  bloc: Get.find<ChannelsCubit>(),
                  builder: (ctx, channelState) {
                    return Text(
                        (channelState is ChannelsLoadedSuccess)
                            ? channelState.selected?.name ?? ''
                            : '',
                        style: Theme.of(context).textTheme.headline1!.copyWith(
                            fontSize: 17, fontWeight: FontWeight.w700));
                  },
                ),
              ),
              BlocBuilder<ChannelsCubit, ChannelsState>(
                bloc: Get.find<ChannelsCubit>(),
                builder: (ctx, channelState) {
                  return Text(
                    AppLocalizations.of(context)!.membersPlural(
                      (channelState as ChannelsLoadedSuccess)
                          .selected!
                          .stats?.members ?? 0,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                  );
                },
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Column(
                    children: [
                      _buildEditChannel(context),
                      Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                      ),
                      _buildChannelSettings(context),
                      Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                      ),
                      _buildMemberManagement(context),
                      Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                      ),
                      _buildFileTile(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildEditChannel(context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final currentState = Get.find<ChannelsCubit>().state;
        if (currentState is ChannelsLoadedSuccess &&
            currentState.selected != null) {
          NavigatorService.instance
              .navigateToEditChannel(currentState.selected!);
        }
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16, left: 10, right: 20),
            child: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.secondary,
              size: 16,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.edit +
                  ' ' +
                  AppLocalizations.of(context)!.channelInfo,
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 15),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.only(right: 10.0, left: 4),
            child: Icon(
              Icons.keyboard_arrow_right,
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }

  _buildChannelSettings(context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final currentState = Get.find<ChannelsCubit>().state;
        if (currentState is ChannelsLoadedSuccess &&
            currentState.selected != null) {
          NavigatorService.instance.navigateToChannelSetting(
              currentState.selected!);
        }
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16, left: 10, right: 20),
            child: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.secondary,
              size: 16,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.channelSettings,
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 15),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.only(right: 10.0, left: 4),
            child: Icon(
              Icons.keyboard_arrow_right,
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }

  _buildMemberManagement(context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final currentState = Get.find<ChannelsCubit>().state;
        if (currentState is ChannelsLoadedSuccess &&
            currentState.selected != null) {
          NavigatorService.instance
              .navigateToChannelMemberManagement(
              currentState.selected!);
        }
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16, left: 10, right: 20),
            child: Image.asset(
              imageGroupBlack,
              color: Theme.of(context).colorScheme.secondary,
              width: 16,
              height: 16,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.memberManagement,
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 15),
            ),
          ),
          BlocBuilder<ChannelsCubit, ChannelsState>(
            bloc: Get.find<ChannelsCubit>(),
            builder: (ctx, channelState) {
              return Text(
                '${(channelState as ChannelsLoadedSuccess).selected!.stats?.members ?? 0}',
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(Icons.keyboard_arrow_right,
                color:
                Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  _buildFileTile(context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final currentState = Get.find<ChannelsCubit>().state;
        if (currentState is ChannelsLoadedSuccess && currentState.selected != null) {
          NavigatorService.instance.navigateToChannelFiles(currentState.selected!);
        }
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16, left: 10, right: 20),
            child: Icon(
              Icons.file_copy,
              color: Theme.of(context).colorScheme.secondary,
              size: 16,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.files,
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 15),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.only(right: 10.0, left: 4),
            child: Icon(
              Icons.keyboard_arrow_right,
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }

}
