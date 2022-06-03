import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:twake/models/message/message.dart';

part 'gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit()
      : super(GalleryState(galleryStateStatus: GalleryStateStatus.init));

  void getGalleryAssets() async {
    //emit(GalleryState(galleryStateStatus: GalleryStateStatus.loading));
    emit(state.copyWith(newGalleryStateStatus: GalleryStateStatus.loading));

    List<Uint8List> uint8List = [];
    Uint8List? uint8;
    List<File> fileList = [];
    File? file;

    /* will need to check permissions move it to Utilities class
    final PermissionState _permissionState = await PhotoManager.requestPermissionExtend();
    if (_permissionState.isAuth) {    
    } else {   
    }*/

    final albums = await PhotoManager.getAssetPathList(
        hasAll: true,
        //  onlyAll: true,
        type: RequestType.common,
        filterOption:
            FilterOptionGroup(imageOption: FilterOption(needTitle: true)));

    // we can go through all albums to get all AssetEntity
    final recentAlbum = albums[0];
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0,
      end: 10000,
    );

    int k = 0;
    // Future.forEach recentAssets
    // Need to set up emit for the gallery like each 3 to 10 iterations
    for (var i = 0; i < recentAssets.length; i++) {
      uint8 = await recentAssets[i].thumbnailData;
      file = await recentAssets[i].file;
      uint8 != null ? uint8List.add(uint8) : null;
      file != null ? fileList.add(file) : null;
      if (k == 5) {
        k = 0;
        emit(GalleryState(
            galleryStateStatus: GalleryStateStatus.done,
            assetsList: uint8List,
            assetEntity: recentAssets,
            fileList: fileList));
      }
      k++;
    }

    if (uint8List.isEmpty)
      emit(GalleryState(galleryStateStatus: GalleryStateStatus.failed));
  }

  void tabChange(int tab) {
    emit(state.copyWith(newSelectedTab: tab));
  }

  void addFileIndex(int index) {
    List<int> indexList = [...state.selectedFilesIndex];
    indexList.contains(index)
        ? indexList.remove(index)
        : indexList.length < 10
            ? indexList.add(index)
            : null;

    emit(GalleryState(
        selectedFilesIndex: indexList,
        galleryStateStatus: GalleryStateStatus.newSelect,
        assetEntity: state.assetEntity,
        assetsList: state.assetsList,
        fileList: state.fileList));
  }

  void clearSelection() {
    emit(state.copyWith(newSelectedFilesIndex: []));
  }

  void galleryInit() {
    emit(GalleryState(galleryStateStatus: GalleryStateStatus.init));
  }
}
