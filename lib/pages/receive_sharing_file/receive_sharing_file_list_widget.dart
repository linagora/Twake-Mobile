import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/widgets/common/file_upload_sharing_title.dart';

class ReceiveSharingFileListWidget extends StatefulWidget {
  const ReceiveSharingFileListWidget({Key? key}) : super(key: key);

  @override
  _ReceiveSharingFileListWidgetState createState() => _ReceiveSharingFileListWidgetState();
}

class _ReceiveSharingFileListWidgetState extends State<ReceiveSharingFileListWidget> {
  late List<ReceiveSharingFile> listFiles;

  @override
  void initState() {
    super.initState();
    listFiles = Get.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildListFiles()
          ],
        ),
      ),
    );
  }

  _buildHeader() {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.secondaryContainer,
          height: 52.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => _handleClickBackButton(),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).colorScheme.surface,
                  )
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context)?.files ?? '',
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
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
      ],
    );
  }

  _buildListFiles() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 32.0),
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisSpacing: 40,
              mainAxisSpacing: 24,
              crossAxisCount: 2),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: listFiles.length,
          itemBuilder: (context, index) {
            return FileUploadSharingTile(receiveSharingFile: listFiles[index]);
          }),
    );
  }

  _handleClickBackButton() {
    Navigator.of(context).pop();
  }
}
