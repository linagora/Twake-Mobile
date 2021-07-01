import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_state.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/pages/workspaces_management/workspace_title.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/widgets/common/rounded_image.dart';

class CompanySelectionWidget extends StatelessWidget {
  final _refreshController = RefreshController();
  final _companiesCubit = Get.find<CompaniesCubit>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      child: Container(
        color: Color(0xffefeef3),
        child: Column(
          children: [
            Stack(
              children: [
                BlocBuilder<CompaniesCubit, CompaniesState>(
                  bloc: _companiesCubit,
                  buildWhen: (previousState, currentState) =>
                      previousState is CompaniesInitial ||
                      currentState is CompaniesLoadSuccess,
                  builder: (context, companyState) {
                    if (companyState is CompaniesLoadSuccess) {
                      return Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16, top: 24),
                          child: Column(
                            children: [
                              RoundedImage(
                                borderRadius: 12.0,
                                width: 44.0,
                                height: 44.0,
                                imageUrl: companyState.selected.logo,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 40,
                                  left: 16,
                                  right: 16,
                                ),
                                child: Text(
                                  companyState.selected.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                    return Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Image.asset(imagePathCancel),
                    onPressed: () => popBack(),
                  ),
                )
              ],
            ),
            // AddWorkspaceTile(title: 'Add a new company'),
            Expanded(
              child: BlocBuilder<CompaniesCubit, CompaniesState>(
                bloc: _companiesCubit,
                buildWhen: (previousState, currentState) =>
                    previousState is CompaniesInitial ||
                    currentState is CompaniesLoadSuccess,
                builder: (context, companiesState) {
                  if (companiesState is CompaniesInitial) {
                    return SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    );
                  } else if (companiesState is CompaniesLoadSuccess) {
                    final companies = companiesState.companies;
                    final selected = companiesState.selected;

                    return SmartRefresher(
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

                              if (company.selectedWorkspace != null)
                                Globals.instance.workspaceIdSet =
                                    company.selectedWorkspace;

                              await Get.find<WorkspacesCubit>().fetch(
                                companyId: company.id,
                                selectedId: company.selectedWorkspace,
                              );

                              Get.find<ChannelsCubit>().fetch(
                                workspaceId: Globals.instance.workspaceId!,
                                companyId: company.id,
                              );

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
                    );
                  }
                  return SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
