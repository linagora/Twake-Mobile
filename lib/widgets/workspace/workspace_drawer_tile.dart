import 'package:flutter/material.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/repositories/badges_repository.dart';
import 'package:twake/widgets/common/badges.dart';
import 'package:twake/widgets/common/rounded_image.dart';
import 'package:twake/widgets/common/twake_button.dart';
import 'package:twake/widgets/workspace/workspace_thumbnail.dart';

typedef OnWorkspaceDrawerTileTap = void Function();

class WorkspaceDrawerTile extends StatelessWidget {
  final bool isSelected;
  final String? logo;
  final String? name;
  final OnWorkspaceDrawerTileTap? onWorkspaceDrawerTileTap;
  final String? workspaceId;

  const WorkspaceDrawerTile({
    required this.isSelected,
    this.onWorkspaceDrawerTileTap,
    this.logo,
    this.name,
    this.workspaceId,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return TwakeButton(
      onTap: onWorkspaceDrawerTileTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Row(
              children: [
                isSelected
                    ? Image.asset(
                  imageSelectedTile,
                  width: 6,
                  height: 44,
                )
                    : SizedBox(
                  width: 6,
                  height: 44,
                ),
                SizedBox(width: 16.0),
                WorkspaceThumbnail(
                  workspaceName: name ?? '',
                  size: 44.0,
                  isSelected: isSelected,
                  borderRadius: 12.0,
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    name ?? '',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
                BadgesCount(type: BadgeType.workspace, id: workspaceId!),
                SizedBox(width: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
