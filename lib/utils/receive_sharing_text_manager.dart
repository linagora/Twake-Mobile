import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rxdart/rxdart.dart';
import 'package:twake/models/receive_sharing/receive_sharing_text.dart';
import 'package:twake/utils/utilities.dart';

class ReceiveSharingTextManager {
  BehaviorSubject<ReceiveSharingText> _pendingListText =
      BehaviorSubject.seeded(ReceiveSharingText.initial());

  BehaviorSubject<ReceiveSharingText> get pendingListText => _pendingListText;

  void init() {
    getReceivingSharingStream().listen((sharedText) async {
      // Note: Prevent handle this when open magic link by validating raw text
      // Can not check JoiningMagicLinkState by ReceivingSharingStream be invoked first
      // Can not use Globals.handlingMagicLink too, by it only be assigned after
      // this ReceivingSharingStream
      if (sharedText != null && sharedText.isNotEmpty) {
        if (Utilities.isTwakeLink(sharedText)) return;
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
