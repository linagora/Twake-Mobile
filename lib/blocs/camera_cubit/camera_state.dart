part of 'camera_cubit.dart';

enum CameraStateStatus { init, loading, found, done, failed }

class CameraState extends Equatable {
  final CameraStateStatus cameraStateStatus;

  final List<CameraDescription> availableCameras;

  const CameraState(
      {this.cameraStateStatus = CameraStateStatus.init,
      this.availableCameras = const []});

  CameraState copyWith(
      {CameraStateStatus? newCameraStateStatus,
      List<CameraDescription>? newAvailableCameras}) {
    return CameraState(
        cameraStateStatus: newCameraStateStatus ?? this.cameraStateStatus,
        availableCameras: newAvailableCameras ?? this.availableCameras);
  }

  @override
  List<Object?> get props => [cameraStateStatus, availableCameras];
}
