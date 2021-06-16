import 'package:flutter/material.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/config/image_path.dart';

typedef OnSelectableChannelTypeClick = void Function(ChannelVisibility);

class SelectableChannelTypeWidget extends StatefulWidget {
  final ChannelVisibility channelVisibility;
  final OnSelectableChannelTypeClick onSelectableChannelTypeClick;

  const SelectableChannelTypeWidget(
      {required this.channelVisibility, required this.onSelectableChannelTypeClick})
      : super();

  @override
  _SelectableChannelTypeWidgetState createState() =>
      _SelectableChannelTypeWidgetState();
}

class _SelectableChannelTypeWidgetState extends State<SelectableChannelTypeWidget> {
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
          color: Colors.white,
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12))
      ),
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
              child: Row(
                children: [
                  SizedBox(width: 16,),
                  Expanded(
                    child: Text("Public",
                        style: TextStyle(
                          color: Color(0xff000000),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        )
                    ),
                  ),
                  _buildSelectedImage(_selectedChannelVisibility == ChannelVisibility.public),
                  SizedBox(width: 16,)
                ]
              )
            ),
          ),
          Divider(height: 1, color: Color(0x1e000000),),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedChannelVisibility = ChannelVisibility.private;
              });
            },
            child: Container(
                height: 48,
                child: Row(
                    children: [
                      SizedBox(width: 16,),
                      Expanded(
                        child: Text("Private",
                            style: TextStyle(
                              color: Color(0xff000000),
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            )
                        ),
                      ),
                      _buildSelectedImage(_selectedChannelVisibility == ChannelVisibility.private),
                      SizedBox(width: 16,)
                    ]
                )
            ),
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
          color: Colors.white,
          border: Border.all(
            color: Color(0x1e000000),
          ),
          borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      height: 24,
      width: 24,
    );
  }
}
