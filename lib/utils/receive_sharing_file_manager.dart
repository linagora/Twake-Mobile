import 'dart:async';
import 'dart:io';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rxdart/rxdart.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';
import 'package:twake/services/service_bundle.dart';

const _filePath = 'file:///';

class ReceiveSharingFileManager {
  BehaviorSubject<List<ReceiveSharingFile>> _pendingListFiles = BehaviorSubject.seeded([]);
  BehaviorSubject<List<ReceiveSharingFile>> get pendingListFiles => _pendingListFiles;
  StreamSubscription? _sharingFileStreamSubscription;

  void init() {
    _sharingFileStreamSubscription = getReceivingSharingStream().listen((listSharedFiles) async {
      if(listSharedFiles.isNotEmpty) {
        clearPendingFile();
        try {
          final listFiles = await Future.wait(listSharedFiles.map((element) {
            final rawPath = Uri.decodeFull(element.path);
            final type = element.type;
            return getFileInfoFromFilePath(rawPath, type);
          }));
          _pendingListFiles.add(listFiles);
        } catch (e) {
          Logger().d('ERROR during receiving sharing file from outside');
        }
      }
    });
  }

  Future<ReceiveSharingFile> getFileInfoFromFilePath(String filePath, SharedMediaType type) async {
    final actualPath = filePath.startsWith(_filePath)
        ? filePath.substring(_filePath.length - 1)
        : filePath;
    final file = File(actualPath);
    final name = actualPath.split('/').last;
    final parentPath = actualPath.substring(0, actualPath.length - name.length);
    return ReceiveSharingFile(name, parentPath, await file.length(), type);
  }

  void clearPendingFile() {
    if(_pendingListFiles.isClosed) {
      _pendingListFiles = BehaviorSubject.seeded([]);
    } else {
      _pendingListFiles.add([]);
    }
  }
  void dispose() {
    _pendingListFiles.close();
    _sharingFileStreamSubscription?.cancel();
  }

  Stream<List<SharedMediaFile>> getReceivingSharingStream() {
    return Rx.merge([
      Stream.fromFuture(ReceiveSharingIntent.getInitialMedia()),
      ReceiveSharingIntent.getMediaStream()
    ]);
  }
}