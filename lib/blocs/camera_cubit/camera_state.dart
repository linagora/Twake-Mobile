part of 'camera_cubit.dart';

enum CameraStateStatus { init, loading, found, done, failed }

class CameraState extends Equatable {
  final CameraStateStatus cameraStateStatus;
  final List<CameraDescription> availableCameras;
  final int flashMode;
  final bool cameraLensModeSwitch;
  const CameraState({
    this.cameraStateStatus = CameraStateStatus.init,
    this.availableCameras = const [],
    this.flashMode = 0,
    this.cameraLensModeSwitch = false,
  });

  CameraState copyWith(
      {CameraStateStatus? newCameraStateStatus,
      List<CameraDescription>? newAvailableCameras,
      int? newFlashMode,
      bool? newCameraLensModeSwitch}) {
    return CameraState(
        cameraStateStatus: newCameraStateStatus ?? this.cameraStateStatus,
        availableCameras: newAvailableCameras ?? this.availableCameras,
        flashMode: newFlashMode ?? this.flashMode,
        cameraLensModeSwitch:
            newCameraLensModeSwitch ?? this.cameraLensModeSwitch);
  }

  @override
  List<Object?> get props =>
      [cameraStateStatus, availableCameras, flashMode, cameraLensModeSwitch];
}
