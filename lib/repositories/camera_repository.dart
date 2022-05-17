import 'package:camera/camera.dart';
import 'package:logger/logger.dart';

class CameraRepository {
  CameraRepository();

  Future<List<CameraDescription>> getCameras() async {
    List<CameraDescription> cameras = [];
    try {
      cameras = await availableCameras();
    } catch (e) {
      Logger().log(Level.error,
          'Error occured during fetch a list of available cameras:\n$e');
      return [];
    }
    return cameras;
  }
}
