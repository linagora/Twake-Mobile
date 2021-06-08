import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/pages/workspaces_management/add_workspace_tile.dart';
import 'package:twake/pages/workspaces_management/workspace_title.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/widgets/common/rounded_image.dart';

class CompanySelectionWidget extends StatelessWidget {
  const CompanySelectionWidget() : super();

  @override
  Widget build(BuildContext context) {
    Get.find<CompaniesCubit>().fetch();

    return Scaffold(
      body: Container(
        color: Color(0xffefeef3),
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Stack(
              children: [
                BlocBuilder<CompaniesCubit, CompaniesState>(
                    bloc: Get.find<CompaniesCubit>(),
                    builder: (context, companyState) {
                      if (companyState is CompaniesLoadSuccess) {
                        return Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, top: 20),
                            child: Column(
                              children: [
                                RoundedImage(
                                  borderRadius: BorderRadius.circular(10),
                                  width: 60,
                                  height: 60,
                                  imageUrl: companyState.selected?.logo,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8, bottom: 40, left: 20, right: 20),
                                  child: Text(
                                    companyState.selected?.name ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
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
                          ));
                    }),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      icon: Image.asset(imagePathCancel),
                      onPressed: () => popBack()),
                )
              ],
            ),
            // AddWorkspaceTile(title: 'Add a new company'),
            Expanded(
              child: BlocBuilder<CompaniesCubit, CompaniesState>(
                bloc: Get.find<CompaniesCubit>(),
                builder: (context, companyState) {
                  if (companyState is CompaniesLoadSuccess) {
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: companyState.companies.length,
                      itemBuilder: (context, index) {
                        final company = companyState.companies[index];
                        return WorkspaceTile(
                          onTap: () => Get.find<CompaniesCubit>()
                              .selectCompany(companyId: company.id),
                          image: company.logo ?? '',
                          title: company.name,
                          selected: companyState.selected?.id == company.id,
                          subtitle: '',
                        );
                      },
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
