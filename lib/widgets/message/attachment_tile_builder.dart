import 'package:flutter/material.dart';
import 'package:get/get.dart';


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
          child: Image.asset(
            leadingIcon,
            width: 32,
            height: 32,
            color: Get.theme.colorScheme.surface,
          )),
      title: Get.isDarkMode
          ? Text(this.title,
              style: Get.theme.textTheme.headline1!
                  .copyWith(fontSize: 17, fontWeight: FontWeight.normal))
          : Text(this.title,
              style: Get.theme.textTheme.headline4!
                  .copyWith(fontSize: 17, fontWeight: FontWeight.normal)),
      subtitle: Text(this.subtitle,
          style: Get.theme.textTheme.headline3!
              .copyWith(fontSize: 14, fontWeight: FontWeight.normal)),
    );
  }
}
