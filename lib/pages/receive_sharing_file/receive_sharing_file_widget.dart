import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/file/local_file.dart';
import 'package:twake/models/file/upload/file_uploading.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/models/receive_sharing/receive_sharing_type.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_item_channel_widget.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_item_company_widget.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_item_ws_widget.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/models/file/file.dart';

class ReceiveSharingFileWidget extends StatefulWidget {
  const ReceiveSharingFileWidget({Key? key}) : super(key: key);

  @override
  _ReceiveSharingFileWidgetState createState() => _ReceiveSharingFileWidgetState();
}

const int maxTextLength = 10;
const double companyItemSize = 100.0;
const double wsItemSize = 48.0;
const double channelItemSize = 48.0;
const double deltaTextItemSize = 12.0;
const _separatorItemHorizontal = 16.0;

class _ReceiveSharingFileWidgetState extends State<ReceiveSharingFileWidget> {

  final receiveFileCubit = Get.find<ReceiveFileCubit>();
  final fileUploadCubit = Get.find<FileUploadCubit>();
  final _textController = TextEditingController();
  final _scrollControllerCompanies = ScrollController();
  final _scrollControllerWorkspaces = ScrollController();
  final _scrollControllerChannels = ScrollController();

  @override
  void initState() {
    super.initState();
    ReceiveSharingType sharingType = Get.arguments;
    if(sharingType == ReceiveSharingType.MediaFile) {
      fileUploadCubit.initSharingFilesStream();
    }
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
        color: Theme.of(context).colorScheme.secondaryContainer,
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
        if(state.sharingType == ReceiveSharingType.Text)
          return SizedBox.shrink();
        return GestureDetector(
          onTap: () => _handleClickTitleFiles(state.listFiles),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                Divider(
                  height: 0.5,
                  color: Theme.of(context).colorScheme.secondaryContainer,
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
                  color: Theme.of(context).colorScheme.secondaryContainer,
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
              controller: _scrollControllerCompanies,
              padding: const EdgeInsets.all(12),
              shrinkWrap: true,
              itemCount: state.listCompanies.length > state.limitCompanyList
                  ? state.limitCompanyList
                  : state.listCompanies.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) => SizedBox(
                  width: _separatorItemHorizontal),
              itemBuilder: (context, index) {
                final companyState = state.listCompanies[index].state;
                final company = state.listCompanies[index].element;
                return ReceiveSharingCompanyItemWidget(
                  company: company,
                  companyState: companyState,
                  onItemSelected: () async {
                    _scrollToPosition(ResourceKind.Company, index);
                  },
                );
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
              controller: _scrollControllerWorkspaces,
              padding: const EdgeInsets.all(6),
              shrinkWrap: true,
              itemCount: state.listWorkspaces.length > state.limitWorkspaceList
                  ? state.limitWorkspaceList
                  : state.listWorkspaces.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) => SizedBox(
                  width: _separatorItemHorizontal),
              itemBuilder: (context, index) {
                final wsState = state.listWorkspaces[index].state;
                final ws = state.listWorkspaces[index].element;
                return ReceiveSharingWSItemWidget(
                  ws: ws,
                  wsState: wsState,
                  onItemSelected: () async {
                    _scrollToPosition(ResourceKind.Workspace, index);
                  },
                );
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
              controller: _scrollControllerChannels,
              padding: const EdgeInsets.all(6),
              shrinkWrap: true,
              itemCount: state.listChannels.length > state.limitChannelList
                  ? state.limitChannelList
                  : state.listChannels.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) => SizedBox(
                  width: _separatorItemHorizontal),
              itemBuilder: (context, index) {
                final channelState = state.listChannels[index].state;
                final channel = state.listChannels[index].element;
                return ReceiveSharingChannelItemWidget(
                  channel: channel,
                  channelState: channelState,
                  onItemSelected: () async {
                    _scrollToPosition(ResourceKind.Channel, index);
                  },
                );
              },
            ),
          ),
        ],
      );

  _buildChatTextFieldAndProgressBar() => BlocBuilder<ReceiveFileCubit, ReceiveShareFileState>(
    bloc: receiveFileCubit,
    builder: (context, state) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _buildLayoutByUploadingStatus(state.status)
      );
    }
  );

  _buildLayoutByUploadingStatus(ReceiveShareFileStatus status) {
    switch(status) {
      case ReceiveShareFileStatus.uploadingFiles:
        return _buildUploadProcessingBackground(
          childWidget: CircularProgressIndicator(
            backgroundColor: const Color.fromRGBO(153, 162, 173, 0.4),
            color: const Color(0xff004dff),
            strokeWidth: 1.0,
          ),
        );
      case ReceiveShareFileStatus.uploadFilesSuccessful:
        return _buildUploadProcessingBackground(
          childWidget: Image.asset(imageDone),
        );
      default:
        return _buildTextField();
    }
  }

  _buildUploadProcessingBackground({required Widget childWidget}) {
    return Container(
      alignment: Alignment.center,
      width: double.maxFinite,
      height: 80.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(const Radius.circular(10.0)),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: childWidget,
    );
  }

  _buildTextField() {
    return BlocBuilder<ReceiveFileCubit, ReceiveShareFileState>(
      bloc: receiveFileCubit,
      builder: (BuildContext context, state) {
        _textController.text = state.receivedText.text;
        return TextField(
          controller: _textController,
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
            fillColor: Theme.of(context).colorScheme.secondaryContainer,
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            hintText: AppLocalizations.of(context)!.addComment,
            hintStyle: Theme.of(context)
                .textTheme
                .headline2!
                .copyWith(fontSize: 13, fontWeight: FontWeight.w500),
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
          ),
        );
      }
    );
  }

  _buildSendButton() => BlocBuilder<ReceiveFileCubit, ReceiveShareFileState>(
      bloc: receiveFileCubit,
      builder: (context, state) {
        if (state.sharingType == ReceiveSharingType.Text) {
          return _buildSendButtonBySharingText(state);
        }
        if(state.sharingType == ReceiveSharingType.MediaFile) {
          return _buildSendButtonBySharingMediaFile(state);
        }
        return SizedBox.shrink();
      });

  _buildSendButtonBySharingText(ReceiveShareFileState state) {
    return GestureDetector(
      onTap: () {
        if(state.status == ReceiveShareFileStatus.sendingMessage)
          return;
        _handleClickSendButton(state);
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        width: double.maxFinite,
        height: 50.0,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          color: state.status == ReceiveShareFileStatus.sendingMessage
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)?.sendButton ?? '',
              style: Theme.of(context).textTheme.headline1!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.0),
            state.status == ReceiveShareFileStatus.sendingMessage
              ? SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    color: Theme.of(context).colorScheme.surface,
                    strokeWidth: 1.0,
                  ))
              : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  _buildSendButtonBySharingMediaFile(ReceiveShareFileState state) {
    return BlocBuilder<FileUploadCubit, FileUploadState>(
      bloc: fileUploadCubit,
      builder: (context, fileState) {
        return GestureDetector(
          onTap: () {
            if(fileState.fileUploadStatus == FileUploadStatus.inProcessing)
              return;
            _handleClickSendButton(state);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Container(
              width: double.maxFinite,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(14)),
                color: fileState.fileUploadStatus == FileUploadStatus.inProcessing
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.surface,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)?.sendButton ?? '',
                    style: Theme.of(context).textTheme.headline1!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    alignment: Alignment.center,
                    width: 18.0,
                    height: 18.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      state.listFiles.length.toString(),
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _handleClickCloseButton() {
    final sharingType = receiveFileCubit.state.sharingType;
    if(sharingType == ReceiveSharingType.MediaFile) {
      fileUploadCubit.clearFileUploadingState(needToCancelInProcessingFile: true);
      fileUploadCubit.closeListSharingStream();
    }
    receiveFileCubit.resetStateData();
    Navigator.of(context).pop();
  }

  _handleClickTitleFiles(List<ReceiveSharingFile> listFiles) {
    NavigatorService.instance.navigateToReceiveSharingFileList(listFiles);
  }

  _handleClickShowAllCompanies() async {
    final selectedIndex =
      await NavigatorService.instance.navigateToReceiveSharingCompanyList();
    _scrollToPosition(ResourceKind.Company, selectedIndex);
  }

  _handleClickShowAllWS() async {
    final selectedIndex =
        await NavigatorService.instance.navigateToReceiveSharingWSList();
    _scrollToPosition(ResourceKind.Workspace, selectedIndex);
  }

  _handleClickShowAllChannels() async {
    final selectedIndex =
        await NavigatorService.instance.navigateToReceiveSharingChannelList();
    _scrollToPosition(ResourceKind.Channel, selectedIndex);
  }

  _handleClickSendButton(ReceiveShareFileState shareFileState) async {
    if(shareFileState.sharingType == ReceiveSharingType.Text) {
      final company = receiveFileCubit.getCurrentSelectedResource(
          kind: ResourceKind.Company) as Company;
      final channel = receiveFileCubit.getCurrentSelectedResource(
          kind: ResourceKind.Channel) as Channel;
      sendMessage(attachments: [], company: company, channel: channel);
      return;
    }
    if(shareFileState.sharingType == ReceiveSharingType.MediaFile) {
      _uploadAndSendMessage();
      return;
    }
  }

  void _uploadAndSendMessage() async {
    // 1. Upload file
    receiveFileCubit.updateStartUploadingStatus();
    final company = receiveFileCubit.getCurrentSelectedResource(
        kind: ResourceKind.Company) as Company;
    receiveFileCubit.state.listFiles.forEach((file) async {
      final localFile = LocalFile(
          name: file.name,
          size: file.size,
          path: file.parentPath + file.name,
          updatedAt: DateTime.now().millisecondsSinceEpoch);
      await fileUploadCubit.upload(
        sourceFile: localFile,
        companyId: company.id,
        sourceFileUploading: SourceFileUploading.FileSharing,
      );
    });

    // 2. Send message when the upload finished
    int _counter = 0;
    await for(var file in fileUploadCubit.streamListSharingFile) {
      if(file.uploadStatus == FileItemUploadStatus.uploaded) {
        _counter++;
      }

      // 2.1 Check file uploading state from file stream
      if(_counter == receiveFileCubit.state.listFiles.length) {
        receiveFileCubit.updateFinishedUploadingStatus();
        final channel = receiveFileCubit.getCurrentSelectedResource(
            kind: ResourceKind.Channel) as Channel;
        List<dynamic> attachments = const [];
        if (fileUploadCubit.state.listFileUploading.isNotEmpty) {
          attachments = fileUploadCubit.state.listFileUploading
              .where((fileUploading) => fileUploading.file != null)
              .map((e) => e.file!.toAttachment())
              .toList();
        }

        // 2.2 Send message
        sendMessage(attachments: attachments, company: company, channel: channel);
      }
    }
  }

  void sendMessage({
    required List<dynamic> attachments,
    required Company company,
    required Channel channel,
  }) async {
    receiveFileCubit.updateStartSendingMessageStatus();
    final ws = receiveFileCubit.getCurrentSelectedResource(
        kind: ResourceKind.Workspace) as Workspace;
    await Get.find<ChannelMessagesCubit>().sendInSharing(
      originalStr: _textController.text,
      attachments: attachments,
      isDirect: channel.isDirect,
      companyId: company.id,
      workspaceId: ws.id,
      channelId: channel.id,
    );

    // 2.3 Close this screen & navigate to shared channel
    Future.delayed(Duration(milliseconds: 500), () async {
      receiveFileCubit.updateSentMessageStatus();
      receiveFileCubit.saveLatestSharedLocation(
        companyId: company.id,
        workspaceId: ws.id,
        channelId: channel.id,
      );
      _handleClickCloseButton();
      _popAllThenBackToInitPage();
      await NavigatorService.instance.navigateToChannelAfterSharedFile(
        companyId: company.id,
        workspaceId: ws.id,
        channelId: channel.id,
      );
    });
  }

  void _popAllThenBackToInitPage() async {
    try {
      Navigator.popUntil(context, ModalRoute.withName(RoutePaths.initial));
    } catch (e) {
      Logger().e('Error occurred during pop all pages in stack:\n$e');
    }
  }

  void _scrollToPosition(ResourceKind kind, int index) async {
    // in general, the horizontal list is limited in limitItems(8) items,
    // once user selects item outside limitation, expand the horizontal list one more item
    if(index >= limitItems) {
      receiveFileCubit.updateNewLimitSize(
        kind: kind,
        newLimitSize: limitItems + 1,
        updatedIndex: index,
      );
    }
    // scroll the list into position
    switch (kind) {
      case ResourceKind.Company:
        await _scrollControllerCompanies.animateTo(
          (index * (companyItemSize + _separatorItemHorizontal)).toDouble(),
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
        break;
      case ResourceKind.Workspace:
        await _scrollControllerWorkspaces.animateTo(
          (index * (wsItemSize + deltaTextItemSize + _separatorItemHorizontal)).toDouble(),
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
        break;
      case ResourceKind.Channel:
        await _scrollControllerChannels.animateTo(
          (index * (channelItemSize + deltaTextItemSize + _separatorItemHorizontal)).toDouble(),
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
        break;
    }
  }

}
