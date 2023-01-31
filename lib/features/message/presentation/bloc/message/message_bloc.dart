import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/features/message/data/model/message/response/message.dart';
import 'package:twake/features/message/domain/usecases/fetch_message_usecase.dart';
import 'package:twake/models/globals/globals.dart';

part 'message_event.dart';

part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final FetchMessageUseCase _fetchMessageUseCase;
  late final ChannelsCubit _baseChannelsCubit;
  final ChannelsCubit _channelsCubit;
  final ChannelsCubit _directsCubit;

  bool? isDirect;

  MessageBloc(
    this._fetchMessageUseCase,
    this._baseChannelsCubit,
    this._channelsCubit,
    this._directsCubit,
  ) : super(MessageInitial()) {
    on<FetchMessageEvent>(
      _handleFetchMessageEvent,
      transformer: restartable(),
    );
  }

  Future<void> _handleFetchMessageEvent(
    FetchMessageEvent event,
    Emitter<MessageState> emit,
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

    final result = _fetchMessageUseCase.execute(
      input: FetchMessageUseCaseInput(
        channelId: event.channelId,
        threadId: event.threadId,
        workspaceId: event.isDirect ? 'direct' : null,
      ),
    );
    result.fold((l) {}, (r) async {
      final threadId = event.threadId ?? Globals.instance.threadId;
      List<Message> lastList = const [];
      await for (var list in r) {
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
    });
  }
}
