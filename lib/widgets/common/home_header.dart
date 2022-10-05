import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/rounded_shimmer.dart';

class HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 44,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BlocBuilder<WorkspacesCubit, WorkspacesState>(
                    bloc: Get.find<WorkspacesCubit>(),
                    builder: (context, workspaceState) {
                      if (workspaceState is WorkspacesLoadSuccess) {
                        return GestureDetector(
                          onTap: () {
                            Get.find<AccountCubit>().fetch();
                            Scaffold.of(context).openDrawer();
                          },
                          child: Container(
                            width: 75,
                            child: Row(
                              children: [
                                ImageWidget(
                                  imageType: ImageType.common,
                                  imageUrl: workspaceState.selected?.logo ?? '',
                                  size: 42,
                                  borderRadius: 10,
                                  name: workspaceState.selected?.name ?? '',
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.9),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          width: 75,
                          child: Row(
                            children: [
                              RoundedShimmer(size: 42),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withOpacity(0.9),
                                size: 24,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    imageTwakeHomeLogo,
                    width: 63,
                    height: 15,
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                _buildHeaderActionButtons(context)
              ],
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  _buildHeaderActionButtons(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BlocBuilder(
                bloc: Get.find<CompaniesCubit>(),
                builder: (ctx, cstate) => (cstate is CompaniesLoadSuccess &&
                        cstate.selected.canShareMagicLink)
                    ? Row(
                        children: [
                          BlocBuilder<WorkspacesCubit, WorkspacesState>(
                            bloc: Get.find<WorkspacesCubit>(),
                            builder: (context, workspaceState) {
                              return workspaceState is WorkspacesLoadSuccess
                                  ? GestureDetector(
                                      onTap: () => push(
                                          RoutePaths.invitationPeople.path,
                                          arguments:
                                              workspaceState.selected?.name ??
                                                  ''),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                          width: 40,
                                          height: 40,
                                          child: Image.asset(
                                            imageInvitePeople,
                                            width: 20,
                                            height: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink();
                            },
                          ),
                          SizedBox(width: 16),
                        ],
                      )
                    : SizedBox.shrink()),
            GestureDetector(
              onTap: () => push(RoutePaths.newDirect.path),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    imageAddChannel,
                    width: 20,
                    height: 20,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
