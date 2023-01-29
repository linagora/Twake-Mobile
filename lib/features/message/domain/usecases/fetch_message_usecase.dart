import 'package:dartz/dartz.dart';
import 'package:twake/core/state/failure.dart';
import 'package:twake/features/message/data/model/message/response/message.dart';
import 'package:twake/features/message/domain/repository/message_repository.dart';

class FetchMessageUseCase {
  final MessageRepository _messageRepository;

  FetchMessageUseCase(
      this._messageRepository,
      );

  Either<ExceptionFailure, Stream<List<Message>>> execute({ String? companyId,
    String? workspaceId,
    required String channelId,
    String? threadId,
    bool? withExistedFiles = false,}) {
    try {
      final stream = _messageRepository.fetch(
        channelId: channelId,
        threadId: threadId,
        workspaceId: workspaceId,
      );
      return Right<ExceptionFailure, Stream<List<Message>>>(stream);
    } catch (e) {
      return Left<ExceptionFailure, Stream<List<Message>>>(ExceptionFailure(e));
    }
  }
}