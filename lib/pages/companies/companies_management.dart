import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/routing/app_router.dart';

import 'company_setting_item_widget.dart';
import 'company_tile.dart';

class CompaniesManagement extends StatelessWidget {
  const CompaniesManagement() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16, top: 20),
                  child: Text(
                    'All companies',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
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
          BlocBuilder<CompaniesCubit, CompaniesState>(
              bloc: Get.find<CompaniesCubit>(),
              builder: (context, companyState) {
                if (companyState is CompaniesLoadSuccess) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Container(
                          color: Colors.redAccent,
                          width: 60,
                          height: 60,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          companyState.selected.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  );
                }
                return SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                  width: 8,
                ),
                itemCount: 10,
                itemBuilder: (context, int index) {
                  return CompanyTile(
                      isSelected: index == 0, logo: '', messageCount: 0);
                },
              ),
            ),
          ),
          SizedBox(
            height: 80,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                CompanySettingItemWidget(),
                SizedBox(
                  height: 16,
                ),
                CompanySettingItemWidget(),
                SizedBox(
                  height: 16,
                ),
                CompanySettingItemWidget(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
