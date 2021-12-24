import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/file/local_file.dart';

extension StringExtension on String {
  bool get isNotReallyEmpty => this.trim().isNotEmpty;

  bool get isReallyEmpty => this.trim().isEmpty;

  // https://github.com/flutter/flutter/issues/18761
  String get overflow => this
      .replaceAll('', '\u{200B}')
      .toString();

  bool get isImageMimeType => this.startsWith('image/');

  bool get isVideoMimeType => this.startsWith('video/');

  String get fileExtension {
    if(this.isEmpty || !this.contains('.'))
      return '';
    final arrFragment = this.split('.');
    if(arrFragment.length < 2)
      return '';
    return this.split('.').last;
  }

  // References:
  // - Archive: https://en.wikipedia.org/wiki/List_of_archive_formats
  // - Office: https://docs.microsoft.com/en-us/deployoffice/compat/office-file-format-reference
  // - Image: https://developer.mozilla.org/en-US/docs/Web/Media/Formats/Image_types
  String get imageAssetByFileExtension {
    switch(this) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'webp':
      case 'svg':
      case 'bmp':
        return imagePhoto;
      case 'pdf':
        return imagePdf;
      case 'zip':
      case 'zipx':
      case 'tar':
      case 'gz':
      case '7z':
      case 'z':
      case 'rar':
        return imageZip;
      case 'doc':
      case 'docx':
      case 'docm':
      case 'dot':
      case 'dotm':
      case 'dotx':
      case 'odt':
        return imageDocument;
      case 'csv':
      case 'ods':
      case 'xla':
      case 'xls':
      case 'xlsb':
      case 'xlsx':
      case 'xlt':
      case 'xps':
        return imageOpenSheet;
      default:
        return imageFile;
    }
  }
}
//
// extension MemberExtension on List<Member?> {
//   List<String?> get ids => this.map((e) => e!.userId).toList();
// }
//
// extension UsersListExtension on List<User> {
//   void excludeUsers(List<User> toExclude) {
//     for (User user in toExclude) {
//       this.removeWhere((element) => element.id == user.id);
//     }
//   }
// }

extension ChunkExtension<T> on List<T> {
  List<List<T>> chunks(int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < this.length; i += chunkSize) {
      chunks.add(this.sublist(
        i,
        i + chunkSize > this.length ? this.length : i + chunkSize,
      ));
    }
    return chunks;
  }
}

extension PlatformFileExtension on PlatformFile {
  LocalFile toLocalFile() => LocalFile(name: name, size: size, path: path);
}

extension XFileExtension on XFile {
  Future<LocalFile> toLocalFile() async {
    final len = await length();
    return LocalFile(name: name, size: len, path: path);
  }
}
