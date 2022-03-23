import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/common/selectable_item.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_file_widget.dart';
import 'package:twake/widgets/common/image_widget.dart';

class ReceiveSharingCompanyItemWidget extends StatefulWidget {
  final Company company;
  final SelectState companyState;
  final Function? onItemSelected;

  const ReceiveSharingCompanyItemWidget({
    Key? key,
    required this.company,
    required this.companyState,
    this.onItemSelected,
  }) : super(key: key);

  @override
  State<ReceiveSharingCompanyItemWidget> createState() =>
      _ReceiveSharingCompanyItemWidgetState();
}

class _ReceiveSharingCompanyItemWidgetState
    extends State<ReceiveSharingCompanyItemWidget> {
  final receiveFileCubit = Get.find<ReceiveFileCubit>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        receiveFileCubit.setSelectedCompany(widget.company);
        widget.onItemSelected?.call();
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: companyItemSize,
                height: companyItemSize,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(const Radius.circular(12.0)),
                    border: widget.companyState == SelectState.SELECTED
                        ? Border.all(color: const Color(0xff007AFF), width: 1.5)
                        : null),
                child: ImageWidget(
                  name: widget.company.name,
                  imageType: ImageType.common,
                  size: 48.0,
                  imageUrl: widget.company.logo ?? '',
                  borderRadius: 12,
                ),
              ),
              widget.companyState == SelectState.SELECTED
                  ? Transform(
                      transform: Matrix4.translationValues(4, -4, 0),
                      child: Image.asset(imageSelectedRoundBlue,
                          width: 20.0, height: 20.0))
                  : SizedBox.shrink(),
            ],
          ),
          SizedBox(height: 4.0),
          Text(
              widget.company.name.length > maxTextLength
                  ? widget.company.name.substring(0, maxTextLength)
                  : widget.company.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
