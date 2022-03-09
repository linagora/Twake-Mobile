import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';

class FileUploadSharingTile extends StatelessWidget {

  final ReceiveSharingFile receiveSharingFile;

  const FileUploadSharingTile({Key? key, required this.receiveSharingFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.all(const Radius.circular(16.0)),
            child: Container(
              width: 135.0,
              height: 135.0,
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: _buildFileTypeIcon(),
            ),
          ),
        ),
        SizedBox(height: 12.0),
        Text(
          receiveSharingFile.name + '\n',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFileTypeIcon() {
    return receiveSharingFile.type == SharedMediaType.IMAGE
        ? Image.file(
            File(receiveSharingFile.parentPath + receiveSharingFile.name),
            width: double.maxFinite,
            height: double.maxFinite,
            fit: BoxFit.cover,
          )
        : Image.asset(
            imageFileBlueBorder,
            width: 24.0,
            height: 24.0,
          );
  }
}
