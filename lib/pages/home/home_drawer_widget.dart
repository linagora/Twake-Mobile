import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_state.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/badge/badge.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/badges.dart';
import 'package:twake/widgets/common/rounded_image.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';

class HomeDrawerWidget extends StatelessWidget {
  const HomeDrawerWidget() : super();

  @override
  Widget build(BuildContext context) {
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
                              child: RoundedImage(
                                width: 56,
                                height: 56,
                                borderRadius: 16.0,
                                imageUrl: companyState.selected.logo ?? '',
                              )),
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
                                      Text("Switch organisation",
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Text(
                    "WORKSPACES",
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
                  bloc: Get.find<WorkspacesCubit>(),
                  builder: (context, workspaceState) {
                    if (workspaceState is WorkspacesLoadSuccess) {
                      return MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.separated(
                            separatorBuilder: (_, __) => SizedBox(height: 16),
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
                            }),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle_sharp,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        GestureDetector(
                          child: Text(
                            "Add a new workspace",
                            style: TextStyle(
                              color: Color(0xff000000),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          onTap: () => NavigatorService.instance
                              .navigateToCreateWorkspace(),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    BlocBuilder<AccountCubit, AccountState>(
                      bloc: Get.find<AccountCubit>(),
                      builder: (context, accountState) {
                        if (accountState is AccountLoadSuccess) {
                          return GestureDetector(
                            onTap: () =>
                                NavigatorService.instance.navigateToAccount(),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: [
                                RoundedImage(
                                  imageUrl:
                                      accountState.account.thumbnail ?? '',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                    '${accountState.account.firstname} ${accountState.account.lastname}',
                                    style: TextStyle(
                                      color: Color(0xff000000),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    )),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
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
              )
            ],
          ),
        ),
      ),
    );
  }

  void _selectWorkspace(BuildContext context, String workSpaceId) {
    Get.find<WorkspacesCubit>().selectWorkspace(workspaceId: workSpaceId);

    Get.find<CompaniesCubit>().selectWorkspace(workspaceId: workSpaceId);

    Get.find<ChannelsCubit>().fetch(
      workspaceId: Globals.instance.workspaceId!,
      companyId: Globals.instance.companyId,
    );

    Get.find<DirectsCubit>().fetch(
        workspaceId: Globals.instance.workspaceId!,
        companyId: Globals.instance.companyId);
    // close drawer
    Navigator.of(context).pop();
  }
}

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
    return GestureDetector(
      onTap: onWorkspaceDrawerTileTap,
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
              RoundedImage(
                imageUrl: logo ?? '',
                width: 44,
                height: 44,
                isSelected: isSelected,
                borderWidth: 2.0,
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
    );
  }
}
