import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

part 'writing_state.dart';

class WritingCubit extends Cubit<WritingState> {
  final _socketIOEventStream = SocketIOService.instance.writingEventStream;
  late Timer timer;
  WritingCubit() : super(WritingState()) {
    listenToWriting();
  }

  void getWritingEvent(
      String userId, String name, String channelId, bool isWriting) async {
    if (Globals.instance.userId == userId) return;

    final Map<String, List<UsersWritingData>> writingMap = {
      ...state.writingMap
    };

    if (writingMap.containsKey(channelId)) {
      writingMap[channelId]!.removeWhere((element) => element.userId == userId);
      if (isWriting)
        writingMap[channelId]!.add(UsersWritingData(userId, name, isWriting));
    } else {
      if (isWriting)
        writingMap[channelId] = [UsersWritingData(userId, name, isWriting)];
    }
    if (writingMap[channelId] != null) {
      writingMap[channelId]!.sort(
        (a, b) => a.name.compareTo(b.name),
      );

      writingMap[channelId]!.isNotEmpty
          ? emit(WritingState(
              writingMap: writingMap,
              writingStatus:
                  isWriting ? WritingStatus.writing : WritingStatus.notWriting,
              thisWritingData: state.thisWritingData,
              timerVal: state.timerVal))
          : emit(WritingState(
              writingMap: writingMap,
              writingStatus: WritingStatus.init,
              thisWritingData: state.thisWritingData,
              timerVal: state.timerVal));
    }
  }

  Future<void> sendWritingEvent(String channelId) async {
    final List<WritingData> thisWritingData = [...state.thisWritingData];
    if (thisWritingData.isEmpty) {
      final name = (Get.find<AccountCubit>().state as AccountLoadSuccess)
          .account
          .fullName;
      final data = WritingData(
          type: "writing",
          event: WritingEvent(
              channelId: channelId,
              threadId: '',
              userId: Globals.instance.userId ?? "",
              name: name,
              isWriting: false));
      thisWritingData.add(data);
      emit(state.copyWith(newThisWritingData: thisWritingData));
      return;
    }
    thisWritingData[0].event.channelId = channelId;

    if (thisWritingData.isNotEmpty &&
        state.timerVal == 0 &&
        !thisWritingData[0].event.isWriting) {
      thisWritingData[0].event.isWriting = true;
      emit(state.copyWith(newThisWritingData: thisWritingData));
      runTimer();
      SynchronizationService.instance.emitWritingEvent(thisWritingData[0]);
    }

    if (state.timerVal != 0 && thisWritingData[0].event.isWriting) {
      emit(state.copyWith(newTimerVal: 0));
    }
  }

  void runTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      emit(state.copyWith(newTimerVal: state.timerVal + 1));
      if (state.timerVal > 2 && state.thisWritingData.isNotEmpty) {
        emit(state.copyWith(newTimerVal: 0));
        state.thisWritingData[0].event.isWriting = false;
        SynchronizationService.instance
            .emitWritingEvent(state.thisWritingData[0]);
        stopTimer();
      }
      // just in case stop when more than 7 secs
      if (state.timerVal > 7) {
        emit(state.copyWith(newTimerVal: 0));
        state.thisWritingData[0].event.isWriting = false;
        SynchronizationService.instance
            .emitWritingEvent(state.thisWritingData[0]);
        stopTimer();
      }
    });
  }

  void stopTimer() {
    timer.cancel();
  }

  Future<void> listenToWriting() async {
    await for (final eventStream in _socketIOEventStream) {
      getWritingEvent(
          eventStream.data.event.userId,
          eventStream.data.event.name,
          eventStream.data.event.channelId,
          eventStream.data.event.isWriting);
    }
  }
}
