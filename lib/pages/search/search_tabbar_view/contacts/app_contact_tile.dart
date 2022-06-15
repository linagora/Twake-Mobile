import 'package:flutter/material.dart';
import 'package:twake/models/contacts/app_contact.dart';
import 'package:twake/widgets/common/image_widget.dart';

class AppContactTile extends StatelessWidget {
  final String? userId;
  final AppContact contact;

  const AppContactTile({Key? key, required this.userId, required this.contact})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 12),
            child: ImageWidget(
              imageType: ImageType.common,
              imageUrl: null,
              size: 40,
              name: contact.localContact.displayName,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                contact.localContact.displayName,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 17, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
