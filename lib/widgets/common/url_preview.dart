import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/cache_in_chat_cubit/cache_in_chat_cubit.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:twake/services/endpoints.dart';
import 'package:twake/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class PreviewDataNotifier extends ValueNotifier<PreviewData?> {
  PreviewDataNotifier() : super(null);
}

class UrlPreview extends StatefulWidget {
  final String url;
  final TextStyle? textStyle;

  const UrlPreview({Key? key, required this.url, this.textStyle}) : super(key: key);

  @override
  _UrlPreviewState createState() => _UrlPreviewState();
}

class _UrlPreviewState extends State<UrlPreview> {

  final PreviewDataNotifier _previewDataNotifier = PreviewDataNotifier();

  @override
  void dispose() {
    _previewDataNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PreviewData? cachedPreviewData =
        Get.find<CacheInChatCubit>().findCachedPreviewData(url: widget.url);
    return Container(
      key: ValueKey(widget.url),
      child: ValueListenableBuilder(
        valueListenable: _previewDataNotifier,
        builder: (BuildContext context, PreviewData? previewData, Widget? child) {
          return LinkPreview(
            enableAnimation: true,
            onPreviewDataFetched: (data) {
              _previewDataNotifier.value = data;
              Get.find<CacheInChatCubit>().cacheUrlPreviewData(
                url: widget.url,
                previewData: data,
              );
            },
            previewData: cachedPreviewData == null ? previewData : cachedPreviewData,
            text: widget.url,
            linkStyle: widget.textStyle,
            headerStyle: widget.textStyle,
            textStyle: widget.textStyle,
            width: double.maxFinite,
            onLinkPressed: (value) {
              _openUrl(value);
            },

            imageBuilder: (imageUrl) {
              return ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(4.0),
                ),
                child: CachedNetworkImage(imageUrl: imageUrl),
              );
            }
          );
        }
      ),
    );
  }

  void _openUrl(String launchUrl) async {
    final canOpen = await canLaunch(launchUrl);
    if (canOpen) {
      if (Platform.isIOS) {
        final launchUri = Uri.parse(launchUrl);
        final token = launchUri.queryParameters['join'];
        final host = launchUri.host;
        if (Endpoint.inSupportedHosts(host)) {
          String newCustomUrl;
          if(token != null && token.isNotEmpty) {
            // To handle magic link
            newCustomUrl = '$TWAKE_MOBILE://$host/?join=$token';
          } else {
            // To handle twake link format:
            // https://{twake_host}/client/{company_id}/w/{workspace_id}/c/{channel_id}
            newCustomUrl = '$TWAKE_MOBILE://$host${launchUri.path}';
          }
          if (await canLaunch(newCustomUrl)) {
            await launch(newCustomUrl);
            return;
          }
        }
      }
      await launch(launchUrl);
    }
  }


}
