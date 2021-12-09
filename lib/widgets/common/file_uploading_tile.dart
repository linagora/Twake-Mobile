import 'package:flutter/material.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/file/upload/file_uploading.dart';

class FileUploadingTile extends StatefulWidget {
  final FileUploading fileUploading;
  final Function? onCancel;

  FileUploadingTile({required this.fileUploading, this.onCancel}) : super();

  @override
  _FileUploadingTileState createState() => _FileUploadingTileState();
}

class _FileUploadingTileState extends State<FileUploadingTile> {
  @override
  Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Color(0xff979797).withOpacity(0.2),
        ),
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPreviewFile(),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(getFileName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16.0)),
                  SizedBox(height: 4),
                  _buildUploadingFileSize()
                ],
              ),
            ),
            GestureDetector(
              onTap: () => widget.onCancel?.call(),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.close),
              ),
            )
          ],
        ),
      );
  }

  // Select one between source name (local)
  // and metadata name (remote) inside file
  String getFileName() {
    if(widget.fileUploading.sourceName != null
        && widget.fileUploading.sourceName!.isNotEmpty) {
      return widget.fileUploading.sourceName!;
    } else if(widget.fileUploading.file != null) {
      return widget.fileUploading.file!.metadata.name.isNotEmpty
        ? widget.fileUploading.file!.metadata.name
        : '';
    }
    return '';
  }

  _buildPreviewFile() {
    if(widget.fileUploading.uploadStatus == FileItemUploadStatus.uploading) {
      return SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator());
    } else {
      return Image.asset(imageFile, width: 32, height: 32);
    }
  }

  _buildUploadingFileSize() {
    if(widget.fileUploading.uploadStatus == FileItemUploadStatus.uploading) {
      return Text('File uploading...',
          style: TextStyle(fontSize: 12.0));
    } else {
      return Text('File uploaded',
          style: TextStyle(fontSize: 12.0));
    }
  }
}
