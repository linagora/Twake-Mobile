import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/file/upload/file_uploading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/extensions.dart';

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
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Theme.of(context).colorScheme.secondaryVariant
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildFileTypeIcon(),
          SizedBox(width: 17.0),
          Expanded(child: _buildFileInfo()),
          SizedBox(width: 20.0),
          _buildUploadStatus(),
          SizedBox(width: 20.0),
          _buildRemoveAction(),
        ],
      ),
    );
  }

  Widget _buildFileTypeIcon() {
    String extension = '';
    if (widget.fileUploading.sourceFile != null) {
      extension = widget.fileUploading.sourceFile!.extension ?? '';
    } else if (widget.fileUploading.file != null) {
      extension = widget.fileUploading.file!.metadata.name.fileExtension;
    }
    return Image.asset(
      extension.imageAssetByFileExtension,
      width: 24.0,
      height: 24.0,
      color:
          extension.imageAssetByFileExtension == imageFile ? Colors.blue : null,
    );
  }

  Widget _buildFileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getFileName(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .headline1!
              .copyWith(fontSize: 17, fontWeight: FontWeight.normal),
        ),
        SizedBox(height: 2),
        Text(
          _getFileMetadata(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .headline1!
              .copyWith(fontSize: 12, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  // Select one between source name (local)
  // and metadata name (remote) inside file
  String _getFileName() {
    if (widget.fileUploading.sourceFile != null &&
        widget.fileUploading.sourceFile!.name.isNotEmpty) {
      return widget.fileUploading.sourceFile!.name;
    } else if (widget.fileUploading.file != null &&
        widget.fileUploading.file!.metadata.name.isNotEmpty) {
      return widget.fileUploading.file!.metadata.name;
    }
    return '';
  }

  String _getFileMetadata() {
    if (widget.fileUploading.sourceFile != null) {
      return AppLocalizations.of(context)?.fileUploadingMetadata(
              filesize(widget.fileUploading.sourceFile!.size),
              DateFormatter.getVerboseDateTime(
                  widget.fileUploading.sourceFile!.updatedAt)) ??
          '';
    } else if (widget.fileUploading.file != null) {
      return AppLocalizations.of(context)?.fileUploadingMetadata(
              filesize(widget.fileUploading.file!.uploadData.size),
              DateFormatter.getVerboseDateTime(
                  widget.fileUploading.file!.updatedAt)) ??
          '';
    }
    return '';
  }

  Widget _buildUploadStatus() {
    switch (widget.fileUploading.uploadStatus) {
      case FileItemUploadStatus.uploading:
        return SizedBox(
          width: 18.0,
          height: 18.0,
          child: CircularProgressIndicator(
            backgroundColor: const Color.fromRGBO(153, 162, 173, 0.4),
            color: const Color(0xff004dff),
            strokeWidth: 1.0,
          ),
        );
      case FileItemUploadStatus.uploaded:
        return Image.asset(imageSelectedRoundBlue, width: 18.0, height: 18.0);
      case FileItemUploadStatus.uploaded:
        return Image.asset(imageError, width: 18.0, height: 18.0);
      default:
        return SizedBox(width: 18.0, height: 18.0);
    }
  }

  Widget _buildRemoveAction() {
    return GestureDetector(
      onTap: () => widget.onCancel?.call(),
      child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: widget.fileUploading.uploadStatus ==
                  FileItemUploadStatus.uploading
              ? Icon(Icons.close, size: 14.0)
              : Image.asset(imageRemove, width: 14.0, height: 14.0)),
    );
  }
}
