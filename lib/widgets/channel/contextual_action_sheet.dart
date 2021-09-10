import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CupertinoWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
            onPressed: () {},
            child: ActionWidget(
              title: AppLocalizations.of(context)!.mute,
              subtitle: AppLocalizations.of(context)!.notificationsStop,
              icon: Icon(
                CupertinoIcons.bell_slash_fill,
                color: Color(0xff004dff),
              ),
            )),
        CupertinoActionSheetAction(
            onPressed: () {},
            child: ActionWidget(
              title: AppLocalizations.of(context)!.pin,
              subtitle: AppLocalizations.of(context)!.pinInfo,
              icon: Icon(
                CupertinoIcons.pin_fill,
                color: Color(0xff004dff),
              ),
            )),
        CupertinoActionSheetAction(
            onPressed: () {},
            child: ActionWidget(
              title: AppLocalizations.of(context)!.archive,
              subtitle: AppLocalizations.of(context)!.archiveInfo,
              icon: Icon(
                CupertinoIcons.archivebox_fill,
                color: Color(0xff004dff),
              ),
            )),
        CupertinoActionSheetAction(
            onPressed: () {},
            child: ActionWidget(
              title: AppLocalizations.of(context)!.markAsUnread,
              subtitle: AppLocalizations.of(context)!.markAsUnreadInfo,
              icon: Icon(
                CupertinoIcons.envelope_open_fill,
                color: Color(0xff004dff),
              ),
            )),
        CupertinoActionSheetAction(
          onPressed: () {},
          child: ActionWidget(
            title: AppLocalizations.of(context)!.delete,
            subtitle: AppLocalizations.of(context)!.notificationsStop,
            isDestructive: true,
            icon: Icon(
              CupertinoIcons.trash_fill,
              color: Color(0xffe64646),
            ),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          AppLocalizations.of(context)!.cancel,
          maxLines: 1,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 19.0,
            fontWeight: FontWeight.w600,
            color: Color(0xff007aff),
          ),
        ),
      ),
    );
  }
}

class ActionWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Icon? icon;
  final bool isDestructive;

  const ActionWidget({
    Key? key,
    this.title,
    this.subtitle,
    this.icon,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          icon!,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title!,
                maxLines: 1,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w400,
                  color: isDestructive ? Color(0xffe64646) : Color(0xff000000),
                ),
              ),
              SizedBox(height: 2.0),
              Text(
                subtitle!,
                maxLines: 1,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff909499),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
