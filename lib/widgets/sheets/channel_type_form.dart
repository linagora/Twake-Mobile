import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/sheet_bloc.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/blocs/add_channel_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChannelTypeForm extends StatefulWidget {
  @override
  _ChannelTypeFormState createState() => _ChannelTypeFormState();
}

class _ChannelTypeFormState extends State<ChannelTypeForm> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddChannelBloc, AddChannelState>(
      listener: (context, state) {
        if (state is Created) {
          // Reload channels
          context.read<ChannelsBloc>().add(ReloadChannels(forceFromApi: true));
          // Close sheet
          context.read<SheetBloc>().add(CloseSheet());
        } else if (state is Error) {
          // Show an error
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
              state.message,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            duration: Duration(seconds: 2),
          ));
        }
      },
      buildWhen: (previous, current) {
        return (current is Updated);
      },
      builder: (context, state) {
        var channelType = ChannelType.public;
        if (state is Updated) {
          channelType = state.repository?.type;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SheetTitleBar(
              title: 'New Channel',
              leadingTitle: 'Back',
              leadingAction: () => context
                  .read<AddChannelBloc>()
                  .add(SetFlowStage(FlowStage.info)),
              trailingTitle: 'Create',
              trailingAction: () =>
                  context.read<AddChannelBloc>().add(Create()),
            ),
            SizedBox(height: 23),
            Padding(
              padding: const EdgeInsets.only(left: 14.0, right: 100.0),
              child: Text(
                'CHANNEL TYPE',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
            SizedBox(height: 6),
            ChannelTypesContainer(type: channelType),
            SizedBox(height: 8),
            HintLine(
              text: channelType != ChannelType.direct
                  ? 'Public channels can be found by everyone, though private can only be joined by invitation'
                  : 'Direct channels involve correspondence between selected members',
            ),
            if (channelType == ChannelType.public) AddAllSwitcher(),
            if (channelType == ChannelType.private) SizedBox(),
            if (channelType == ChannelType.direct) ParticipantsButton(),
            HintLine(
              text: channelType != ChannelType.private
                  ? (channelType != ChannelType.direct
                      ? 'Only available for public channels'
                      : 'Only available for direct channels')
                  : '',
            ),
          ],
        );
      },
    );
  }
}

class ChannelTypesContainer extends StatelessWidget {
  final ChannelType type;

  const ChannelTypesContainer({
    Key key,
    @required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Divider(
          thickness: 0.5,
          height: 0.5,
          color: Colors.black.withOpacity(0.2),
        ),
        SelectableItem(
          title: 'Public',
          selected: type == ChannelType.public,
          onTap: () => context
              .read<AddChannelBloc>()
              .add(Update(type: ChannelType.public)),
        ),
        SelectableItem(
          title: 'Private',
          selected: type == ChannelType.private,
          onTap: () => context
              .read<AddChannelBloc>()
              .add(Update(type: ChannelType.private)),
        ),
        SelectableItem(
          title: 'Direct',
          selected: type == ChannelType.direct,
          onTap: () => context
              .read<AddChannelBloc>()
              .add(Update(type: ChannelType.direct)),
        ),
      ],
    );
  }
}

class SelectableItem extends StatelessWidget {
  final String title;
  final bool selected;
  final Function onTap;

  const SelectableItem({
    Key key,
    @required this.title,
    @required this.selected,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.0,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    if (selected)
                      Icon(
                        CupertinoIcons.check_mark,
                        color: Color(0xff837cfe),
                      ),
                  ],
                ),
              ),
            ),
            Divider(
              indent: 15.0,
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .read<AddChannelBloc>()
          .add(SetFlowStage(FlowStage.participants)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 21, 14, 8),
        child: ParticipantsCommonWidget(
          title: 'Added participants',
          trailingWidget: BlocBuilder<AddChannelBloc, AddChannelState>(
              builder: (context, state) {
            var participantsCount = 0;
            if (state is Updated) {
              final participants = state.repository?.members;
              participantsCount = participants.length;
            }
            return participantsCount > 0
                ? Row(
                    children: [
                      Text(
                        '$participantsCount',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff837cfe),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.forward,
                        color: Color(0xff837cfe),
                      ),
                    ],
                  )
                : Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff837cfe),
                    ),
                  );
          }),
        ),
      ),
    );
  }
}

class AddAllSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 21, 14, 8),
      child: ParticipantsCommonWidget(
        title: 'Automatically add new users',
        trailingWidget: BlocBuilder<AddChannelBloc, AddChannelState>(
          builder: (context, state) {
            var shouldAddAll = true;
            if (state is Updated) {
              shouldAddAll = state.repository.def;
            }
            return CupertinoSwitch(
              value: shouldAddAll,
              onChanged: (value) {
                context
                    .read<AddChannelBloc>()
                    .add(Update(automaticallyAddNew: value));
              },
            );
          },
        ),
      ),
    );
  }
}

class ParticipantsCommonWidget extends StatelessWidget {
  final String title;
  final Widget trailingWidget;

  const ParticipantsCommonWidget({
    Key key,
    @required this.title,
    @required this.trailingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          Spacer(),
          trailingWidget,
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
