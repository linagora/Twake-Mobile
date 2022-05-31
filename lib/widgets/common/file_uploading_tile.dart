import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:twake/models/file/upload/file_uploading.dart';

class FileUploadingTile extends StatefulWidget {
  final FileUploading fileUploading;
  final Uint8List? thumbnail;
  final String? thumbnailUrl;
  final Function? onCancel;

  FileUploadingTile(
      {required this.fileUploading,
      this.onCancel,
      this.thumbnail,
      this.thumbnailUrl})
      : super();

  @override
  _FileUploadingTileState createState() => _FileUploadingTileState();
}

class _FileUploadingTileState extends State<FileUploadingTile> {
  Widget _buildImage() {
    // remote file
    if (widget.thumbnailUrl != null) {
      return Image.network(
        widget.thumbnailUrl!,
        fit: BoxFit.fill,
      );
    }

    // local file
    return widget.fileUploading.uploadStatus == FileItemUploadStatus.uploading
        ? Image.memory(
            widget.thumbnail!,
            colorBlendMode: BlendMode.multiply,
            color: Theme.of(context).colorScheme.secondary,
            fit: BoxFit.fill,
          )
        : Image.memory(
            widget.thumbnail!,
            fit: BoxFit.fill,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 87,
          width: 87,
          child: Stack(
            children: [
              Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => widget.onCancel?.call(),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            Positioned(
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color!
                                      .withOpacity(0.9),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 4,
                              child: Icon(
                                Icons.close,
                                size: 16.0,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              widget.fileUploading.uploadStatus ==
                      FileItemUploadStatus.uploading
                  ? Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
