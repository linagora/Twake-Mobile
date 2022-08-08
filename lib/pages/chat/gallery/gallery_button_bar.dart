import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/file_transition_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/models/file/local_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/models/globals/globals.dart';

class GalleryButtonBar extends StatelessWidget {
  final _controller = TextEditingController();

  _handleUploadFiles() {
    Get.find<FileUploadCubit>().initFileUploadingStream();
    final state = Get.find<GalleryCubit>().state;
    for (var i = 0; i < state.selectedFilesIndex.length; i++) {
      final LocalFile localFile = LocalFile(
          name: state.assetEntity[state.selectedFilesIndex[i]].title!,
          path: state.fileList[state.selectedFilesIndex[i]].path,
          thumbnail: state.assetsList[state.selectedFilesIndex[i]],
          size: state.fileList[state.selectedFilesIndex[i]].lengthSync(),
          updatedAt: DateTime.now().millisecondsSinceEpoch);

      Get.find<FileUploadCubit>().upload(
        sourceFile: localFile,
        sourceFileUploading: SourceFileUploading.InChat,
      );
    }
    _controller.text.isNotEmpty
        ? Get.find<FileTransitionCubit>().messageInprogressFileLoading()
        : Get.find<FileTransitionCubit>().fileLoadingMessageEmpty();

    Get.back();
  }

  _handleMessageSend() async {
    if (_controller.text.isNotEmpty) {
      final channel =
          (Get.find<ChannelsCubit>().state as ChannelsLoadedSuccess).selected!;
      Globals.instance.threadId == null
          ? Get.find<ChannelMessagesCubit>().send(
              originalStr: _controller.text,
              isDirect: channel.isDirect,
            )
          : Get.find<ThreadMessagesCubit>().send(
              originalStr: _controller.text,
              isDirect: channel.isDirect,
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryCubit, GalleryState>(
      bloc: Get.find<GalleryCubit>(),
      builder: (context, state) {
        return state.selectedTab == 0
            ? state.selectedFilesIndex.length != 0
                ? SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 12, right: 4, bottom: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    child: TextField(
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1!
                                          .copyWith(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400),
                                      maxLines: 4,
                                      minLines: 1,
                                      controller: _controller,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      keyboardAppearance: Theme.of(context)
                                          .colorScheme
                                          .brightness,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        contentPadding: const EdgeInsets.only(
                                            left: 12,
                                            right: 25,
                                            top: 4,
                                            bottom: 4),
                                        hintText: AppLocalizations.of(context)!
                                            .newReply,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .copyWith(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _handleMessageSend();
                                  _handleUploadFiles();
                                },
                                child: Container(
                                    height: 40,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                        child: Text(
                                      AppLocalizations.of(context)!.sendButton,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1!
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                    ))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink()
            : SizedBox.shrink();
      },
    );
  }
}
