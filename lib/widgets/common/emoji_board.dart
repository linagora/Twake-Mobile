
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/pages/chat/chat.dart';

class EmojiBoard extends StatelessWidget {
  final void Function(String) onEmojiSelected;

  EmojiBoard({required this.onEmojiSelected});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (cat, emoji) {
          onEmojiSelected(emoji.emoji);
          Chat.of(context).endAnimation();
        },
        config: Config(
          columns: 7,
          emojiSizeMax: 32.0,
          verticalSpacing: 0,
          horizontalSpacing: 0,
          initCategory: Category.RECENT,
          bgColor: Theme.of(context).colorScheme.secondaryContainer,
          indicatorColor: Theme.of(context).colorScheme.surface,
          iconColor: Theme.of(context).colorScheme.secondary,
          iconColorSelected: Theme.of(context).colorScheme.surface,
          progressIndicatorColor: Theme.of(context).colorScheme.surface,
          showRecentsTab: true,
          recentsLimit: 28,
          noRecentsText: AppLocalizations.of(context)!.noRecents,
          noRecentsStyle:
              Theme.of(context).textTheme.headline3!.copyWith(fontSize: 20),
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL,
        ),
      ),
    );
  }
}