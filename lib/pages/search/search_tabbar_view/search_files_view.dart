import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/pages/search/search_tabbar_view/files/file_item.dart';
import 'package:twake/pages/search/search_tabbar_view/files/files_status_informer.dart';
import 'package:twake/repositories/search_repository.dart';

class SearchFilesView extends StatefulWidget {
  @override
  State<SearchFilesView> createState() => _SearchFilesViewState();
}

class _SearchFilesViewState extends State<SearchFilesView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: Get.find<SearchCubit>(),
      builder: (context, state) {
        if (state.filesStateStatus == FilesStateStatus.done &&
            state.files.isNotEmpty) {
          return SizedBox.expand(
            child: ListView(children: [
              FilesSection(
                searchTerm: state.searchTerm,
                files: state.files,
              )
            ]),
          );
        }

        return FileStatusInformer(
            status: state.filesStateStatus,
            searchTerm: state.searchTerm,
            onResetTap: () => Get.find<SearchCubit>().resetSearch());
      },
    );
  }
}

class FilesSection extends StatelessWidget {
  final List<SearchFile> files;
  final String searchTerm;

  const FilesSection({Key? key, required this.files, required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: files.length,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemBuilder: (context, index) {
        return FileItem(
          searchTerm: searchTerm,
          message: files[index].message,
          file: files[index].file,
          user: files[index].user,
          //channel: files[index].channel,
        );
      },
    );
  }
}
