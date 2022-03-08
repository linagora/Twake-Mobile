import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/common/selectable_item.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_item_company_widget.dart';
import 'package:twake/widgets/common/image_widget.dart';

class ReceiveSharingWSListWidget extends StatefulWidget {
  const ReceiveSharingWSListWidget({Key? key}) : super(key: key);

  @override
  _ReceiveSharingWSListWidgetState createState() => _ReceiveSharingWSListWidgetState();
}

class _ReceiveSharingWSListWidgetState extends State<ReceiveSharingWSListWidget> {
  final receiveFileCubit = Get.find<ReceiveFileCubit>();
  String companyName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [_buildHeader(), _buildList()],
        ),
      ),
    );
  }

  _buildHeader() {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.secondaryVariant,
          height: 52.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).colorScheme.surface,
                    )),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context)?.workspaces.capitalizeFirst ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 0.5,
          color: Theme.of(context).colorScheme.secondaryVariant,
        ),
      ],
    );
  }

  _buildList() {
    return BlocBuilder<ReceiveFileCubit, ReceiveShareFileState>(
      bloc: receiveFileCubit,
      builder: (context, state) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 32.0),
            child: ListView.separated(
              padding: const EdgeInsets.all(6),
              shrinkWrap: true,
              itemCount: state.listWorkspaces.length,
              separatorBuilder: (BuildContext context, int index) => SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final wsState = state.listWorkspaces[index].state;
                final ws = state.listWorkspaces[index].element;
                return buildWSItem(ws, wsState);
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildWSItem(Workspace ws, SelectState wsState) {
    final com = receiveFileCubit.getCurrentSelectedResource(kind: ResourceKind.Company) as Company;
    companyName = com.name;
    return GestureDetector(
      onTap: () => receiveFileCubit.setSelectedWS(ws),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(const Radius.circular(12.0)),
                    border: wsState == SelectState.SELECTED
                        ? Border.all(color: const Color(0xff007AFF), width: 1.5)
                       : null),
                child: ImageWidget(
                  name: ws.name,
                  imageType: ImageType.common,
                  size: 48.0,
                  imageUrl: ws.logo ?? '',
                  borderRadius: 12,
                ),
              ),
              wsState == SelectState.SELECTED
                  ? Transform(
                      transform: Matrix4.translationValues(4, -4, 0),
                      child: Image.asset(imageSelectedRoundBlue, width: 16.0, height: 16.0))
                  : SizedBox.shrink(),
            ],
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ws.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline1!),
                SizedBox(height: 4.0),
                Text(companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
