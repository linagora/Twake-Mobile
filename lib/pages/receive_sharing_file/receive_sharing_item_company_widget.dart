import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/common/selectable_item.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/widgets/common/image_widget.dart';

const int MAX_TEXT_LEN = 16;

class ReceiveSharingCompanyItemWidget extends StatefulWidget {
  final Company company;
  final SelectState companyState;

  const ReceiveSharingCompanyItemWidget({Key? key, required this.company, required this.companyState})
      : super(key: key);

  @override
  State<ReceiveSharingCompanyItemWidget> createState() => _ReceiveSharingCompanyItemWidgetState();
}

class _ReceiveSharingCompanyItemWidgetState extends State<ReceiveSharingCompanyItemWidget> {
  final receiveFileCubit = Get.find<ReceiveFileCubit>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => receiveFileCubit.setSelectedCompany(widget.company),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 100.0,
                height: 100.0,
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
                ),
              ),
              widget.companyState == SelectState.SELECTED
                  ? Transform(
                      transform: Matrix4.translationValues(4, -4, 0),
                      child: Image.asset(imageSelectedRoundBlue, width: 20.0, height: 20.0))
                  : SizedBox.shrink(),
            ],
          ),
          SizedBox(height: 4.0),
          Text(
              widget.company.name.length > MAX_TEXT_LEN
                  ? widget.company.name.substring(0, MAX_TEXT_LEN)
                  : widget.company.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
