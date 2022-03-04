import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_item_company_widget.dart';

class ReceiveSharingCompanyListWidget extends StatefulWidget {
  const ReceiveSharingCompanyListWidget({Key? key}) : super(key: key);

  @override
  _ReceiveSharingCompanyListWidgetState createState() => _ReceiveSharingCompanyListWidgetState();
}

class _ReceiveSharingCompanyListWidgetState extends State<ReceiveSharingCompanyListWidget> {
  final receiveFileCubit = Get.find<ReceiveFileCubit>();

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
                  AppLocalizations.of(context)?.companies ?? '',
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
            child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 24,
                    crossAxisCount: 2),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: state.listCompanies.length,
                itemBuilder: (context, index) {
                  final companyState = state.listCompanies[index].state;
                  final company = state.listCompanies[index].element;
                  return ReceiveSharingCompanyItemWidget(
                      company: company, companyState: companyState);
                }),
          ),
        );
      },
    );
  }
}
