import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_state.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/pages/workspaces_management/workspace_title.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/rounded_widget.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';

class CompanySelectionWidget extends StatelessWidget {
  final _refreshController = RefreshController();
  final _companiesCubit = Get.find<CompaniesCubit>();

  @override
  Widget build(BuildContext context) {
    return RoundedWidget(
      roundedTopOnly: true,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: BlocBuilder<CompaniesCubit, CompaniesState>(
          bloc: _companiesCubit,
          buildWhen: (previousState, currentState) =>
              previousState is CompaniesInitial ||
              currentState is CompaniesLoadSuccess,
          builder: (context, companiesState) {
            if (companiesState is CompaniesLoadSuccess) {
              final companies = companiesState.companies;
              final selected = companiesState.selected;

              return Column(
                children: [
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16, top: 24),
                          child: Column(
                            children: [
                              ImageWidget(
                                imageType: ImageType.common,
                                size: 56,
                                borderRadius: 16,
                                imageUrl: companiesState.selected.logo ?? '',
                                name: companiesState.selected.name,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 40,
                                  left: 16,
                                  right: 16,
                                ),
                                child: Text(companiesState.selected.name,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17)),
                              )
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Image.asset(imagePathCancel),
                          onPressed: () => popBack(),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: SmartRefresher(
                      controller: _refreshController,
                      onRefresh: () async {
                        await _companiesCubit.fetch();
                        await Future.delayed(Duration(seconds: 1));
                        _refreshController.refreshCompleted();
                      },
                      child: ListView.builder(
                        shrinkWrap: false,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: companiesState.companies.length,
                        itemBuilder: (context, index) {
                          final company = companies[index];
                          return WorkspaceTile(
                            onTap: () async {
                              _companiesCubit.selectCompany(
                                companyId: company.id,
                              );
                              popBack();

                              await Get.find<WorkspacesCubit>().fetch(
                                companyId: company.id,
                                selectedId: company.selectedWorkspace,
                              );

                              Get.find<ChannelsCubit>().fetch(
                                workspaceId: Globals.instance.workspaceId!,
                                companyId: company.id,
                              );

                              Get.find<BadgesCubit>().fetch();

                              Get.find<DirectsCubit>().fetch(
                                workspaceId: 'direct',
                                companyId: company.id,
                              );
                            },
                            image: company.logo ?? '',
                            title: company.name,
                            selected: selected.id == company.id,
                            subtitle: '',
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return TwakeCircularProgressIndicator(width: 40, height: 40);
            }
          },
        ),
      ),
    );
  }
}
