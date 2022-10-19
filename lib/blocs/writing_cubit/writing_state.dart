part of 'writing_cubit.dart';

enum WritingStatus { writing, notWriting, init }

class WritingState extends Equatable {
  final WritingStatus writingStatus;
  final Map<String, List<UsersWritingData>> writingMap;
  final List<WritingData> thisWritingData;
  final int timerVal;
  const WritingState(
      {this.writingStatus = WritingStatus.notWriting,
      this.writingMap = const {},
      this.thisWritingData = const [],
      this.timerVal = 0});

  WritingState copyWith(
      {WritingStatus? newWritingStatus,
      Map<String, List<UsersWritingData>>? newWritingMap,
      List<WritingData>? newThisWritingData,
      int? newTimerVal}) {
    return WritingState(
        writingStatus: newWritingStatus ?? this.writingStatus,
        writingMap: newWritingMap ?? this.writingMap,
        thisWritingData: newThisWritingData ?? this.thisWritingData,
        timerVal: newTimerVal ?? this.timerVal);
  }

  @override
  List<Object> get props =>
      [writingStatus, writingMap, thisWritingData, timerVal];
}

class UsersWritingData extends Equatable {
  final String userId;
  final String name;
  final bool isWriting;

  UsersWritingData(
    this.userId,
    this.name,
    this.isWriting,
  );
  @override
  List<Object> get props => [userId, name, isWriting];
}
