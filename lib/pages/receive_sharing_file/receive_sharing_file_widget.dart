import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/widgets/common/button_text_builder.dart';

class ReceiveSharingFileWidget extends StatefulWidget {
  const ReceiveSharingFileWidget({Key? key}) : super(key: key);

  @override
  _ReceiveSharingFileWidgetState createState() => _ReceiveSharingFileWidgetState();
}

class _ReceiveSharingFileWidgetState extends State<ReceiveSharingFileWidget> {
  // late List<ReceiveSharingFile> listFiles;
  // final receiveFileCubit = Get.find<ReceiveFileCubit>();

  @override
  void initState() {
    super.initState();
    // listFiles = Get.arguments;
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   receiveFileCubit.addNewFiles(listFiles);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFileRow(),
            Expanded(child: _buildChildListInside()),
            _buildChatTextFieldAndProgressBar(),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  _buildHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: const Radius.circular(10.0)),
      child: Container(
        color: Colors.white,
        height: 52.0,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)?.shareToTwake ?? '',
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _handleClickCloseButton(),
                child: Image.asset(
                  imageClose,
                  width: 24.0,
                  height: 24.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildFileRow() {
    return BlocBuilder<ReceiveFileCubit, ReceiveShareFileState>(
      bloc: Get.find<ReceiveFileCubit>(),
      builder: (context, state) {
        return GestureDetector(
          onTap: () => _handleClickTitleFiles(state.listFiles),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                Divider(
                  height: 0.5,
                  color: Theme.of(context).colorScheme.secondaryVariant,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
                  child: Row(
                    children: [
                      Image.asset(
                        imageFileBlueBorder,
                        width: 24.0,
                        height: 24.0,
                      ),
                      SizedBox(width: 20.0),
                      Expanded(
                        child: state.listFiles.isAllImages()
                            ? Text(AppLocalizations.of(context)?.shareImages(state.listFiles.length) ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(fontSize: 17))
                            : Text(
                          AppLocalizations.of(context)?.shareFiles(state.listFiles.length) ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .headline1!
                              .copyWith(fontSize: 17),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          imageArrowForward,
                          width: 24.0,
                          height: 24.0,
                        ),
                      )
                    ],
                  ),
                ),
                Divider(
                  height: 0.5,
                  color: Theme.of(context).colorScheme.secondaryVariant,
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  _buildChildListInside() => Container(
    width: double.maxFinite,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChildListCompanies(),
          _buildChildListWorkspaces(),
          _buildChildListChannels(),
        ],
      ),
    ),
  );

  _buildChildListCompanies() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppLocalizations.of(context)?.companies ?? '',
        style: Theme.of(context)
            .textTheme
            .headline1!
            .copyWith(fontWeight: FontWeight.bold, fontSize: 17),
      ),
      SizedBox(height: 12.0),
      Container(
        height: 100.0,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: 20,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (BuildContext context, int index) => SizedBox(width: 16.0),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 100.0,
              height: 100.0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(const Radius.circular(12.0))),),
            );
          },
        ),
      ),
    ],
  );

  _buildChildListWorkspaces() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 16.0),
      Text(
        AppLocalizations.of(context)?.workspaces.capitalizeFirst ?? '',
        style: Theme.of(context)
            .textTheme
            .headline1!
            .copyWith(fontWeight: FontWeight.bold, fontSize: 17, ),
      ),
      SizedBox(height: 12.0),
      Container(
        height: 48.0,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: 20,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (BuildContext context, int index) => SizedBox(width: 16.0),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 48.0,
              height: 48.0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(const Radius.circular(12.0))),),
            );
          },
        ),
      ),
    ],
  );

  _buildChildListChannels() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 16.0),
      Text(
        AppLocalizations.of(context)?.to ?? '',
        style: Theme.of(context)
            .textTheme
            .headline1!
            .copyWith(fontWeight: FontWeight.bold, fontSize: 17, ),
      ),
      SizedBox(height: 12.0),
      Container(
        height: 48.0,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: 20,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (BuildContext context, int index) => SizedBox(width: 16.0),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 48.0,
              height: 48.0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  _buildChatTextFieldAndProgressBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Stack(
      children: [
        _buildTextField()
      ],
    ),
  );

  _buildTextField() {
    return TextField(
      style: Theme.of(context)
          .textTheme
          .headline1!
          .copyWith(fontSize: 17, fontWeight: FontWeight.w400),
      maxLines: 4,
      minLines: 1,
      textCapitalization: TextCapitalization.sentences,
      keyboardAppearance: Theme.of(context).colorScheme.brightness,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondaryVariant,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        hintText: AppLocalizations.of(context)!.addComment,
        hintStyle: Theme.of(context)
            .textTheme
            .headline2!
            .copyWith(fontSize: 13, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(const Radius.circular(10.0)),
          borderSide: BorderSide(
            width: 0.5,
            color: Colors.black.withOpacity(0.12),
            style: BorderStyle.solid,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(const Radius.circular(10.0)),
          borderSide: BorderSide(
            width: 0.5,
            color: Colors.black.withOpacity(0.12),
            style: BorderStyle.solid,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(const Radius.circular(10.0)),
          borderSide: BorderSide(
            width: 0.5,
            color: Colors.black.withOpacity(0.12),
            style: BorderStyle.solid,
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  _buildSendButton() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    child: ButtonTextBuilder(Key('button_send'),
        onButtonClick: () => _handleClickSendButton(),
        backgroundColor: Theme.of(context).colorScheme.surface)
      .setText(AppLocalizations.of(context)?.sendButton ?? '')
      .setHeight(50)
      .setBorderRadius(BorderRadius.all(Radius.circular(14)))
      .build(),
  );

  _handleClickCloseButton() {
    Navigator.of(context).pop();
  }

  _handleClickTitleFiles(List<ReceiveSharingFile> listFiles) {
    NavigatorService.instance.navigateToReceiveSharingFileList(listFiles);
  }

  _handleClickSendButton() {}

}
