import 'package:flutter/material.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef OnSelectableChannelTypeClick = void Function(ChannelVisibility);

class SelectableChannelTypeWidget extends StatefulWidget {
  final ChannelVisibility channelVisibility;
  final OnSelectableChannelTypeClick onSelectableChannelTypeClick;

  const SelectableChannelTypeWidget(
      {required this.channelVisibility,
      required this.onSelectableChannelTypeClick})
      : super();

  @override
  _SelectableChannelTypeWidgetState createState() =>
      _SelectableChannelTypeWidgetState();
}

class _SelectableChannelTypeWidgetState
    extends State<SelectableChannelTypeWidget> {
  late ChannelVisibility _selectedChannelVisibility;

  @override
  void initState() {
    super.initState();
    _selectedChannelVisibility = widget.channelVisibility;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedChannelVisibility = ChannelVisibility.public;
              });
              widget.onSelectableChannelTypeClick(ChannelVisibility.public);
            },
            child: Container(
                height: 48,
                child: Row(children: [
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.public,
                        style: Theme.of(context).textTheme.headline1!.copyWith(
                            fontWeight: FontWeight.w400, fontSize: 17)),
                  ),
                  _buildSelectedImage(
                      _selectedChannelVisibility == ChannelVisibility.public),
                  SizedBox(
                    width: 16,
                  )
                ])),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedChannelVisibility = ChannelVisibility.private;
              });
              widget.onSelectableChannelTypeClick(ChannelVisibility.private);
            },
            child: Container(
                height: 48,
                child: Row(children: [
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.private,
                        style: Theme.of(context).textTheme.headline1!.copyWith(
                            fontWeight: FontWeight.w400, fontSize: 17)),
                  ),
                  _buildSelectedImage(
                      _selectedChannelVisibility == ChannelVisibility.private),
                  SizedBox(
                    width: 16,
                  )
                ])),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImage(bool isSelected) {
    return isSelected
        ? Image.asset(
            imageSelectedRoundBlue,
            width: 24,
            height: 24,
          )
        : _UnselectedChanelTypeImage();
  }
}

class _UnselectedChanelTypeImage extends StatelessWidget {
  const _UnselectedChanelTypeImage() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
          borderRadius: BorderRadius.all(Radius.circular(12))),
      height: 24,
      width: 24,
    );
  }
}
