import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';

final urlRegExp = RegExp(
    r'[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)');

class LinkContentPreviewInput extends StatefulWidget {
  final TextEditingController controller;

  LinkContentPreviewInput({Key? key, required this.controller})
      : super(key: key);

  @override
  State<LinkContentPreviewInput> createState() =>
      _LinkContentPreviewInputState();
}

class _LinkContentPreviewInputState extends State<LinkContentPreviewInput> {
  late final _controller = widget.controller;
  String? matchUrl;
  final hasPreviewLinkListener = ValueNotifier<Metadata?>(null);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() async {
      final text = _controller.text;
      if (!text.contains("https://") && !text.contains("http://")) {
        hasPreviewLinkListener.value = null;
        return;
      }

      final match = urlRegExp.firstMatch(text);
      if (match != null && match.groupCount > 0) {
        matchUrl = match[0] ?? "";
        try {
          final result = await AnyLinkPreview.getMetadata(link: matchUrl!);
          if (result != null) {
            hasPreviewLinkListener.value = result;
            return;
          }
        } catch (e) {
          hasPreviewLinkListener.value = null;
        }
      }
      hasPreviewLinkListener.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Metadata?>(
        valueListenable: hasPreviewLinkListener,
        builder: ((context, hasPreviewLinkValue, child) {
          bool hasPreviewLink = hasPreviewLinkValue != null;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: hasPreviewLink ? 1.0 : 0,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: hasPreviewLink ? 50 : 0,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  border: Border(
                    top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3)),
                    bottom: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.1)),
                  ),
                ),
                // transform:
                //     Matrix4.translationValues(0, hasPreviewLink ? -50 : 0, 0),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.link),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasPreviewLinkListener.value?.title ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            hasPreviewLinkValue?.desc ?? "",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: InkWell(
                          child: const Icon(Icons.close),
                          onTap: () {
                            // close the preview link in input
                            hasPreviewLinkListener.value = null;
                          }),
                    ),
                  ],
                )),
          );
        }));
  }
}
