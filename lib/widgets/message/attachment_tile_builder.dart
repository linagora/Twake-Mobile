import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:twake/config/styles_config.dart';

class AttachmentTileBuilder {
  final String leadingIcon;
  final String title;
  final String subtitle;
  Function? onClick;

  AttachmentTileBuilder(
      {required this.leadingIcon,
      required this.title,
      required this.subtitle,
      this.onClick});

  Widget build() {
    return ListTile(
      onTap: () => onClick?.call(),
      leading: Container(
        height: double.infinity,
        child: Image.asset(leadingIcon, width: 32, height: 32)),
      title: Text(
        this.title,
        style: StylesConfig.commonTextStyle.copyWith(
          color: const Color(0xff004dff),
          fontSize: 17.0,
        ),
      ),
      subtitle: Text(
        this.subtitle,
        style: StylesConfig.commonTextStyle.copyWith(
          color: const Color(0xff818c99),
          fontSize: 14.0,
        ),
      ),
    );
  }
}
