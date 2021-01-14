import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/widgets/sheets/channel_info_text_form.dart';
import 'package:twake/widgets/sheets/channel_name_container.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/blocs/add_channel_bloc.dart';

class ChannelTypeForm extends StatefulWidget {
  @override
  _ChannelTypeFormState createState() => _ChannelTypeFormState();
}

class _ChannelTypeFormState extends State<ChannelTypeForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SheetTitleBar(
          title: 'New Channel',
          trailingTitle: 'Create',
          trailingAction: () => print('CREATE!'),
        ),
        SizedBox(height: 16),
        HintLine(
          text:
              'Direct channels involve correspondence between selected members',
        ),
        SizedBox(height: 20),
        // Container(
        //   padding: const EdgeInsets.only(left: 14.0, right: 7),
        //   color: Colors.white,
        //   child: ChannelInfoTextForm(
        //     hint: 'Channel description',
        //     controller: _descriptionController,
        //     focusNode: _channelDescriptionFocusNode,
        //   ),
        // ),
        SizedBox(height: 8),
        HintLine(
          text: 'Only available for direct channels',
        ),
      ],
    );
  }
}

class ChannelTypesContainer extends StatelessWidget {
  final ChannelType selectedType;

  const ChannelTypesContainer({Key key, this.selectedType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
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
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Public',
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
    );
  }
}
