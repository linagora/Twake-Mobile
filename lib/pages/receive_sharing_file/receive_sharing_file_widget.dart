import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_item_channel_widget.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_item_company_widget.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_item_ws_widget.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/widgets/common/button_text_builder.dart';

class ReceiveSharingFileWidget extends StatefulWidget {
  const ReceiveSharingFileWidget({Key? key}) : super(key: key);

  @override
  _ReceiveSharingFileWidgetState createState() => _ReceiveSharingFileWidgetState();
}

class _ReceiveSharingFileWidgetState extends State<ReceiveSharingFileWidget> {

  final receiveFileCubit = Get.find<ReceiveFileCubit>();

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
      bloc: receiveFileCubit,
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

  _buildChildListInside() => BlocBuilder<ReceiveFileCubit, ReceiveShareFileState>(
      bloc: receiveFileCubit,
      builder: (context, state) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChildListCompanies(state),
                _buildChildListWorkspaces(state),
                _buildChildListChannels(state),
              ],
            ),
          ),
        );
      });

  _buildChildListCompanies(ReceiveShareFileState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.companies ?? '',
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              GestureDetector(
                  onTap: () => _handleClickShowAllCompanies(),
                  child: Text(
                    AppLocalizations.of(context)?.showAll ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(fontSize: 15),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.0),
          Container(
            height: 148.0,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              shrinkWrap: true,
              itemCount: state.listCompanies.length > LIMIT_ITEM
                  ? LIMIT_ITEM
                  : state.listCompanies.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) => SizedBox(width: 16.0),
              itemBuilder: (context, index) {
                final companyState = state.listCompanies[index].state;
                final company = state.listCompanies[index].element;
                return ReceiveSharingCompanyItemWidget(company: company, companyState: companyState);
              },
            ),
          ),
        ],
      );

  _buildChildListWorkspaces(ReceiveShareFileState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.workspaces.capitalizeFirst ?? '',
                style: Theme.of(context).textTheme.headline1!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              GestureDetector(
                onTap: () => _handleClickShowAllWS(),
                child: Text(
                  AppLocalizations.of(context)?.showAll ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Container(
            height: 96.0,
            child: ListView.separated(
              padding: const EdgeInsets.all(6),
              shrinkWrap: true,
              itemCount: state.listWorkspaces.length > LIMIT_ITEM
                  ? LIMIT_ITEM
                  : state.listWorkspaces.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) => SizedBox(width: 16.0),
              itemBuilder: (context, index) {
                final wsState = state.listWorkspaces[index].state;
                final ws = state.listWorkspaces[index].element;
                return ReceiveSharingWSItemWidget(ws: ws, wsState: wsState);
              },
            ),
          ),
        ],
      );

  _buildChildListChannels(ReceiveShareFileState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.to ?? '',
                style: Theme.of(context).textTheme.headline1!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
              ),
              GestureDetector(
                onTap: () => _handleClickShowAllChannels(),
                child: Text(
                  AppLocalizations.of(context)?.showAll ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Container(
            height: 96.0,
            child: ListView.separated(
              padding: const EdgeInsets.all(6),
              shrinkWrap: true,
              itemCount: state.listChannels.length > LIMIT_ITEM
                  ? LIMIT_ITEM
                  : state.listChannels.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) => SizedBox(width: 16.0),
              itemBuilder: (context, index) {
                final channelState = state.listChannels[index].state;
                final channel = state.listChannels[index].element;
                return ReceiveSharingChannelItemWidget(channel: channel, channelState: channelState);
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

  _handleClickShowAllCompanies() {
    NavigatorService.instance.navigateToReceiveSharingCompanyList();
  }

  _handleClickShowAllWS() {
    NavigatorService.instance.navigateToReceiveSharingWSList();
  }

  _handleClickShowAllChannels() {
    NavigatorService.instance.navigateToReceiveSharingChannelList();
  }

  _handleClickSendButton() {}

}
