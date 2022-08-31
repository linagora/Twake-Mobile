import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/repositories/camera_repository.dart';
import 'package:twake/utils/utilities.dart';

part 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  late final CameraRepository _repository;

  CameraCubit({CameraRepository? repository})
      : super(CameraState(cameraStateStatus: CameraStateStatus.init)) {
    if (repository == null) {
      repository = CameraRepository();
    }
    _repository = repository;
  }

  void getCamera() async {
    final bool isGranted = await Utilities.checkCameraPermission();
    if (isGranted == false) {
      emit(CameraState(
        cameraStateStatus: CameraStateStatus.failed,
      ));
      return;
    }

    emit(CameraState(cameraStateStatus: CameraStateStatus.loading));
    final cameras = await _repository.getCameras();
    if (cameras.isEmpty) {
      emit(CameraState(
        cameraStateStatus: CameraStateStatus.failed,
      ));
    } else {
      emit(CameraState(
          cameraStateStatus: CameraStateStatus.found,
          availableCameras: cameras,
          cameraLensModeSwitch: false,
          flashMode: 0));
    }
  }

  void cameraFailed() async {
    emit(
      CameraState(
        cameraStateStatus: CameraStateStatus.failed,
      ),
    );
  }

  void cameraDone() async {
    emit(
      CameraState(
          flashMode: state.flashMode,
          cameraLensModeSwitch: state.cameraLensModeSwitch,
          cameraStateStatus: CameraStateStatus.done,
          availableCameras: state.availableCameras),
    );
  }

  void cameraLensSwitch() async {
    emit(state.copyWith(newCameraLensModeSwitch: !state.cameraLensModeSwitch));
  }

  void nextFlashMode() async {
    final newMode = state.flashMode == 2 ? 0 : state.flashMode + 1;
    emit(state.copyWith(newFlashMode: newMode));
  }
}
