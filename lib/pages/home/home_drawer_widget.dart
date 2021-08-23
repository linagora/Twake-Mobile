import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_state.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';
import 'package:twake/widgets/workspace/workspace_drawer_tile.dart';

class HomeDrawerWidget extends StatelessWidget {
  final _refreshController = RefreshController();
  final _workspacesCubit = Get.find<WorkspacesCubit>();

  @override
  Widget build(BuildContext context) {
    // refetch workspaces
    _workspacesCubit.fetch(
      companyId: Globals.instance.companyId,
    );
    Get.find<CompaniesCubit>().fetch();

    return Drawer(
      child: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                height: 70,
                child: BlocBuilder<CompaniesCubit, CompaniesState>(
                  bloc: Get.find<CompaniesCubit>(),
                  builder: (context, companyState) {
                    if (companyState is CompaniesLoadSuccess) {
                      return Stack(
                        children: [
                          Positioned(
                            left: 16,
                            child: ImageWidget(
                              imageType: ImageType.common,
                              size: 56,
                              borderRadius: 16,
                              imageUrl: companyState.selected.logo ?? '',
                              name: companyState.selected.name,
                              backgroundColor: Color(0xfff5f5f5),
                            ),
                          ),
                          Positioned.fill(
                            left: 82,
                            top: 12,
                            child: Column(
                              children: [
                                Align(
                                  child: Text(companyState.selected.name,
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: Color(0xff000000),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal,
                                      )),
                                  alignment: Alignment.topLeft,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    NavigatorService.instance.showCompanies();
                                  },
                                  child: Row(
                                    children: [
                                      Text('Switch organisation',
                                          style: TextStyle(
                                            color: Color(0xff004dff),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.normal,
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: Icon(
                                          Icons.arrow_forward_ios_sharp,
                                          size: 8,
                                          color: Color(0xff004dff),
                                        ),
                                      ),
                                      Expanded(child: SizedBox.shrink())
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    }
                    return TwakeCircularProgressIndicator();
                  },
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 20, bottom: 12),
                  child: Text(
                    'WORKSPACES',
                    style: TextStyle(
                      color: Color(0x59000000),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<WorkspacesCubit, WorkspacesState>(
                  bloc: _workspacesCubit,
                  buildWhen: (previousState, currentState) =>
                      previousState is WorkspacesInitial ||
                      currentState is WorkspacesLoadSuccess,
                  builder: (context, workspaceState) {
                    if (workspaceState is WorkspacesLoadSuccess) {
                      return MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: SmartRefresher(
                          controller: _refreshController,
                          onRefresh: () async {
                            await _workspacesCubit.fetch(
                              companyId: Globals.instance.companyId,
                            );
                            await Future.delayed(Duration(seconds: 1));
                            _refreshController.refreshCompleted();
                          },
                          child: ListView.builder(
                            itemCount: workspaceState.workspaces.length,
                            itemBuilder: (context, index) {
                              final workSpace =
                                  workspaceState.workspaces[index];
                              return WorkspaceDrawerTile(
                                name: workSpace.name,
                                logo: workSpace.logo,
                                isSelected:
                                    workSpace.id == workspaceState.selected?.id,
                                onWorkspaceDrawerTileTap: () =>
                                    _selectWorkspace(context, workSpace.id),
                                workspaceId: workSpace.id,
                              );
                            },
                          ),
                        ),
                      );
                    }
                    return TwakeCircularProgressIndicator();
                  },
                ),
              ),
              Divider(
                color: Colors.grey,
                height: 1,
              ),
              BlocBuilder(
                bloc: Get.find<CompaniesCubit>(),
                builder: (ctx, cstate) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if ((cstate as CompaniesLoadSuccess)
                          .selected
                          .canCreateWorkspace)
                        GestureDetector(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle_sharp,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  'Add a new workspace',
                                  style: TextStyle(
                                    color: Color(0xff000000),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // close drawer
                              Navigator.of(context).pop();
                              NavigatorService.instance
                                  .navigateToCreateWorkspace();
                            }),
                      if (cstate.selected.canCreateWorkspace)
                        SizedBox(
                          height: 20,
                        ),
                      BlocBuilder<AccountCubit, AccountState>(
                        bloc: Get.find<AccountCubit>(),
                        builder: (context, accountState) {
                          if (accountState is AccountLoadSuccess) {
                            return GestureDetector(
                              onTap: () {
                                // close drawer
                                Navigator.of(context).pop();
                                NavigatorService.instance.navigateToAccount();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ImageWidget(
                                    name: accountState.account.fullName,
                                    imageType: ImageType.common,
                                    size: 26,
                                    imageUrl:
                                        accountState.account.picture ?? '',
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: Dim.widthPercent(55),
                                    ),
                                    child:
                                        Text('${accountState.account.fullName}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Color(0xff000000),
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                            )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: Icon(Icons.arrow_forward_ios_sharp,
                                        size: 10, color: Colors.black),
                                  ),
                                  Expanded(child: SizedBox.shrink())
                                ],
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _selectWorkspace(BuildContext context, String workspaceId) {
    Get.find<WorkspacesCubit>().selectWorkspace(workspaceId: workspaceId);

    Get.find<ChannelsCubit>().fetch(
      workspaceId: workspaceId,
      companyId: Globals.instance.companyId,
    );
    DefaultTabController.of(context)?.animateTo(0);

    Get.find<CompaniesCubit>().selectWorkspace(workspaceId: workspaceId);
    // close drawer
    Navigator.of(context).pop();
  }
}
