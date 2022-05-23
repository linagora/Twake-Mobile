import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/company_files_cubit/company_file_cubit.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

class FilesListView extends StatelessWidget {
  final ScrollController scrollController;
  final _searchController = TextEditingController();

  FilesListView({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView(
      controller: scrollController,
      children: [
        Container(
          color: Get.isDarkMode
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TwakeSearchTextField(
                  height: 40,
                  controller: _searchController,
                  hintText: AppLocalizations.of(context)!.search,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.add,
                      size: 32,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Add local storage file",
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Twake files",
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                BlocBuilder<CompanyFileCubit, CompanyFileState>(
                  bloc: Get.find<CompanyFileCubit>(),
                  builder: (context, state) {
                    if (state.companyFileStatus == CompanyFileStatus.done) {
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 50,
                              width: 50,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.folder,
                                    size: 40,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Dummy file",
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
        )
      ],
    ));
  }
}
