import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/file_cubit/file_transition_cubit.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:image/image.dart' as IMG;
import 'package:twake/repositories/messages_repository.dart';

class MessageFileUploading extends StatelessWidget {
  const MessageFileUploading({required this.message, Key? key})
      : super(key: key);
  final Message message;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileTransitionCubit, FileTransitionState>(
      bloc: Get.find<FileTransitionCubit>(),
      builder: (context, state) {
        if (state.fileTransitionStatus ==
                FileTransitionStatus.messageSentFileLoading &&
            state.messages.first.id == message.id) {
          return buildThumbnail(context);
        } else if (state.fileTransitionStatus ==
                FileTransitionStatus.messageEmptyFileLoading &&
            message.id == dummyId) {
          return buildThumbnail(context);
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget buildThumbnail(BuildContext context) {
    final galleryCubitState = Get.find<GalleryCubit>().state;
    return Container(
      constraints: BoxConstraints(maxHeight: Dim.heightPercent(70)),
      child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: galleryCubitState.selectedFilesIndex.length,
          itemBuilder: (_, index) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: Dim.heightPercent(70) *
                      _aspectRatioCoefficient(galleryCubitState.assetsList[
                          galleryCubitState.selectedFilesIndex[index]]),
                  width: Dim.widthPercent(70),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        galleryCubitState.assetsList[
                            galleryCubitState.selectedFilesIndex[index]],
                        fit: BoxFit.cover,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              Positioned(
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color!
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 5,
                                bottom: 5,
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  num _aspectRatioCoefficient(Uint8List uint8List) {
    final IMG.Image? img = IMG.decodeImage(uint8List);
    final num aspectRatio = img != null ? img.width / img.height : 1;
    final num coefficientHeight = aspectRatio > 1 ? 1 / aspectRatio : 1;
    return coefficientHeight;
  }
}
