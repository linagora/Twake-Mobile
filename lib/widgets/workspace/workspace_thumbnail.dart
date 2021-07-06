import 'package:flutter/material.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/widgets/common/named_avatar.dart';
import 'package:twake/widgets/common/rounded_shimmer.dart';

class WorkspaceThumbnail extends StatelessWidget {
  final String workspaceName;
  final double size;
  final bool isSelected;
  final double borderRadius;

  const WorkspaceThumbnail({
    Key? key,
    this.workspaceName = '',
    this.size = 60.0,
    this.isSelected = false,
    this.borderRadius = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (workspaceName.isNotReallyEmpty) {
      return NamedAvatar(
        size: size,
        name: workspaceName,
        backgroundColor: Color(0xfff5f5f5),
        fontColor: Colors.black,
        borderColor: isSelected ? Color(0xff004dff) : Colors.transparent,
        borderRadius: borderRadius > 0.0 ? borderRadius : size / 2,
      );
    } else {
      return RoundedShimmer(size: size);
    }
  }
}
