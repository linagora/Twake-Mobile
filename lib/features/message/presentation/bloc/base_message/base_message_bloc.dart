import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/features/message/data/model/message/response/message.dart';
import 'package:twake/features/message/domain/repository/message_repository.dart';
import 'package:twake/models/globals/globals.dart';

part 'base_message_event.dart';

part 'base_message_state.dart';

class BaseMessageBloc extends Bloc<BaseMessageEvent, BaseMessageState> {
  final MessageRepository _repository;
  late final BaseChannelsCubit _baseChannelsCubit;
  final BaseChannelsCubit _channelsCubit;
  final BaseChannelsCubit _directsCubit;

  bool? isDirect;

  BaseMessageBloc(
    this._repository,
    this._baseChannelsCubit,
    this._channelsCubit,
    this._directsCubit,
  ) : super(BaseMessageInitial()) {
    on<FetchMessageEvent>(
      (event, emit) {
        _handleFetchMessageEvent(event, emit);
      },
      transformer: restartable(),
    );
  }

  Future<void> _handleFetchMessageEvent(
    FetchMessageEvent event,
    Emitter<BaseMessageState> emit,
  ) async {
    this.isDirect = event.isDirect;
    if (event.isDirect) {
      _baseChannelsCubit = _directsCubit;
    } else {
      _baseChannelsCubit = _channelsCubit;
    }

    if (event.empty) {
      emit(NoMessagesFound());
      return;
    }

    if (event.threadId == null) emit(MessagesLoadInProgress());

    final stream = _repository.fetch(
      channelId: event.channelId,
      threadId: event.threadId,
      workspaceId: event.isDirect ? 'direct' : null,
    );

    final threadId = event.threadId ?? Globals.instance.threadId;

    List<Message> lastList = const [];
    await for (var list in stream) {
      lastList = list;

      emit(MessagesLoadSuccess(
        messages: list,
        hash: list.fold(0, (acc, m) => acc + m.hash),
      ));

      if (lastList.isEmpty && threadId == null) {
        emit(NoMessagesFound());
      }
    }

    _baseChannelsCubit.markChannelRead(channelId: event.channelId);
  }
}
