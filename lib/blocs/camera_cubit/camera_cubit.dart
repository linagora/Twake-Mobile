import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/repositories/camera_repository.dart';

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
    emit(CameraState(cameraStateStatus: CameraStateStatus.loading));
    // cameras[0] is front, next one is back
    final cameras = await _repository.getCameras();
    if (cameras.isEmpty) {
      emit(CameraState(
        cameraStateStatus: CameraStateStatus.failed,
      ));
    } else {
      emit(CameraState(
          cameraStateStatus: CameraStateStatus.found,
          availableCameras: cameras));
    }
  }
}
