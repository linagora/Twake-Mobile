part of 'gallery_cubit.dart';

enum GalleryStateStatus {
  init,
  loading,
  done,
  failed,
  newSelect,
}

class GalleryState extends Equatable {
  final GalleryStateStatus galleryStateStatus;
  final List<Uint8List> assetsList;
  final List<AssetEntity> assetEntity;
  final List<File> fileList;
  final List<int> selectedFilesIndex;
  final int selectedTab;
  final int loadedAssetsAmount;
  final bool isAddingDummyAssets;

  const GalleryState(
      {this.galleryStateStatus = GalleryStateStatus.init,
      this.assetsList = const [],
      this.assetEntity = const [],
      this.fileList = const [],
      this.selectedFilesIndex = const [],
      this.selectedTab = 0,
      this.loadedAssetsAmount = 0,
      this.isAddingDummyAssets = false});

  GalleryState copyWith(
      {GalleryStateStatus? newGalleryStateStatus,
      List<Uint8List>? newAssetsList,
      List<AssetEntity>? newAssetEntity,
      List<File>? newFileList,
      List<int>? newSelectedFilesIndex,
      int? newSelectedTab,
      List<Message>? newMessage,
      int? newLoadedAssetsAmount,
      bool? newIsAddingDummyAssets}) {
    return GalleryState(
        galleryStateStatus: newGalleryStateStatus ?? this.galleryStateStatus,
        assetsList: newAssetsList ?? this.assetsList,
        assetEntity: newAssetEntity ?? this.assetEntity,
        fileList: newFileList ?? this.fileList,
        selectedFilesIndex: newSelectedFilesIndex ?? this.selectedFilesIndex,
        selectedTab: newSelectedTab ?? this.selectedTab,
        loadedAssetsAmount: newLoadedAssetsAmount ?? this.loadedAssetsAmount,
        isAddingDummyAssets:
            newIsAddingDummyAssets ?? this.isAddingDummyAssets);
  }

  @override
  List<Object?> get props => [
        galleryStateStatus,
        assetsList,
        assetEntity,
        fileList,
        selectedFilesIndex,
        selectedTab,
        loadedAssetsAmount,
        isAddingDummyAssets
      ];
}
