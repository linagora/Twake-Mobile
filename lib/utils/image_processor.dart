import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart';

class DecodeParam {
  final File file;
  final int width;
  final int height;
  final SendPort sendPort;

  DecodeParam(
    this.file,
    this.sendPort, {
    this.width = 120,
    this.height,
  });
}

void decodeIsolate(DecodeParam param) {
  // Read an image from file (webp in this case).
  // decodeImage will identify the format of the image and use the appropriate
  // decoder.
  var image = decodeImage(param.file.readAsBytesSync());
  // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
  var thumbnail = copyResize(image, width: param.width,);
  param.sendPort.send(thumbnail);
}

Future<File> processFile(File file) async {
  final receivePort = ReceivePort();

  await Isolate.spawn(
      decodeIsolate, DecodeParam(file, receivePort.sendPort));
  // Get the processed image from the isolate.
  var image = await receivePort.first as Image;

  return await File('twake_profile_picture.jpg').writeAsBytes(encodeJpg(image));
}

// Decode and process an image file in a separate thread (isolate) to avoid
// stalling the main UI thread.
// void main() async {

// }
