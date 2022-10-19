import 'package:flutter/material.dart';
import 'package:twake/models/message/message_link.dart';

class PreviewLinkContentChat extends StatefulWidget {

  final MessageLink messageLink;

  const PreviewLinkContentChat({required this.messageLink});

  @override
  State<PreviewLinkContentChat> createState() => _PreviewLinkContentChatState();
}

class _PreviewLinkContentChatState extends State<PreviewLinkContentChat> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              margin: const EdgeInsets.only(right: 4, top: 2),
              width: 4,
              foregroundDecoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.messageLink.img != null)
                    // need to be handle
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.messageLink.img!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) => Container(),
                          loadingBuilder: ((context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  Builder(
                      builder: (context) => FaviconDomainLine(
                          favicon: widget.messageLink.favicon,
                          domain: widget.messageLink.domain)),
                  if (widget.messageLink.title != null)
                    Text(widget.messageLink.title!,
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w500)),
                  if (widget.messageLink.description != null)
                    Text(
                      widget.messageLink.description!,
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                ],
              ),
            )
          ]),
        ),
      ],
    );
  }
}

class FaviconDomainLine extends StatelessWidget {

  final String? favicon;
  final String? domain;
  final double? fontSize;

  const FaviconDomainLine({
    Key? key,
    this.favicon,
    this.domain,
    this.fontSize,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (favicon != null)
          // the favicon should have the same height as the domain name
          SizedBox(
            height: (fontSize == null ? 14 : fontSize)! *
                MediaQuery.of(context).textScaleFactor,
            child: Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Image.network(
                  favicon!,
                  fit: BoxFit.contain,
                  errorBuilder: ((context, error, stackTrace) => SizedBox()),
                  cacheHeight: 14,
                  cacheWidth: 14,
                )),
          ),
        if (domain != null)
          Text(
            domain!,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize),
          ),
      ],
    );
  }

}
