import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rxdart/rxdart.dart';
import 'package:twake/models/receive_sharing/receive_sharing_text.dart';

class ReceiveSharingTextManager {
  BehaviorSubject<ReceiveSharingText> _pendingListText =
      BehaviorSubject.seeded(ReceiveSharingText.initial());

  BehaviorSubject<ReceiveSharingText> get pendingListText => _pendingListText;

  void init() {
    getReceivingSharingStream().listen((sharedText) async {
      if (sharedText != null && sharedText.isNotEmpty) {
        clearPendingText();
        _pendingListText.add(ReceiveSharingText(sharedText));
      }
    });
  }

  void clearPendingText() {
    if (_pendingListText.isClosed) {
      _pendingListText = BehaviorSubject.seeded(ReceiveSharingText.initial());
    } else {
      _pendingListText.add(ReceiveSharingText.initial());
    }
  }

  void dispose() {
    clearPendingText();
  }

  Stream<String?> getReceivingSharingStream() {
    return Rx.merge([
      Stream.fromFuture(ReceiveSharingIntent.getInitialText()),
      ReceiveSharingIntent.getTextStream()
    ]);
  }
}
