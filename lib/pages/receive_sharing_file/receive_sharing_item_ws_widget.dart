import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/common/selectable_item.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_file_widget.dart';
import 'package:twake/widgets/common/image_widget.dart';

class ReceiveSharingWSItemWidget extends StatefulWidget {
  final Workspace ws;
  final SelectState wsState;
  final Function? onItemSelected;

  const ReceiveSharingWSItemWidget({
    Key? key,
    required this.ws,
    required this.wsState,
    this.onItemSelected,
  }) : super(key: key);

  @override
  State<ReceiveSharingWSItemWidget> createState() => _ReceiveSharingWSItemWidgetState();
}

class _ReceiveSharingWSItemWidgetState extends State<ReceiveSharingWSItemWidget> {
  final receiveFileCubit = Get.find<ReceiveFileCubit>();
  String companyName = '';

  @override
  Widget build(BuildContext context) {
    final com = receiveFileCubit.getCurrentSelectedResource(kind: ResourceKind.Company) as Company;
    companyName = com.name;
    return GestureDetector(
      onTap: () {
        receiveFileCubit.setSelectedWS(widget.ws);
        widget.onItemSelected?.call();
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: wsItemSize,
                height: wsItemSize,
                decoration: BoxDecoration(
                   borderRadius: BorderRadius.all(const Radius.circular(12.0)),
                    border: widget.wsState == SelectState.SELECTED
                        ? Border.all(color: const Color(0xff007AFF), width: 1.5)
                        : null),
                child: ImageWidget(
                  name: widget.ws.name,
                  imageType: ImageType.common,
                  size: wsItemSize,
                  imageUrl: widget.ws.logo ?? '',
                  borderRadius: 12,
                ),
              ),
              widget.wsState == SelectState.SELECTED
                  ? Transform(
                      transform: Matrix4.translationValues(4, -4, 0),
                      child: Image.asset(imageSelectedRoundBlue, width: 16.0, height: 16.0))
                  : SizedBox.shrink(),
            ],
          ),
          SizedBox(height: 4.0),
          Text(
              widget.ws.name.length > maxTextLength
                  ? widget.ws.name.substring(0, maxTextLength)
                  : widget.ws.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 14)),
          SizedBox(height: 4.0),
          Text(companyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 8)),
        ],
      ),
    );
  }
}
