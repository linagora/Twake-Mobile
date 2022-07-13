import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UnreadBorder extends StatelessWidget {
  const UnreadBorder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        alignment: Alignment.center,
        height: 24,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        child: Stack(alignment: Alignment.center, children: [
          Text(AppLocalizations.of(context)!.unreadMessages,
              style: Theme.of(context).textTheme.bodySmall),
          Container(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.arrow_downward,
                    size: 16.0,
                    color: Theme.of(context).colorScheme.background),
              ),
              alignment: Alignment.centerRight)
        ]),
      ),
    );
  }
}