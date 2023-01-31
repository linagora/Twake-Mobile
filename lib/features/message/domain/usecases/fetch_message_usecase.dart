import 'package:dartz/dartz.dart';
import 'package:twake/core/domain/state/failure.dart';
import 'package:twake/core/domain/use_case/use_case.dart';
import 'package:twake/features/message/data/model/message/response/message.dart';
import 'package:twake/features/message/domain/repository/message_repository.dart';

class FetchMessageUseCase
    extends UseCase<FetchMessageUseCaseInput, Stream<List<Message>>> {
  final MessageRepository _messageRepository;

  FetchMessageUseCase(
    this._messageRepository,
  );

  @override
  Either<ExceptionFailure, Stream<List<Message>>> execute({
    required FetchMessageUseCaseInput input,
  }) {
    try {
      final stream = _messageRepository.fetch(
        channelId: input.channelId,
        threadId: input.threadId,
        workspaceId: input.workspaceId,
      );
      return Right<ExceptionFailure, Stream<List<Message>>>(stream);
    } catch (e) {
      return Left<ExceptionFailure, Stream<List<Message>>>(ExceptionFailure(e));
    }
  }
}

class FetchMessageUseCaseInput extends UseCaseInput {
  final String? workspaceId;
  final String channelId;
  final String? threadId;
  final bool withExistedFiles;

  FetchMessageUseCaseInput({
    this.workspaceId,
    required this.channelId,
    this.threadId,
    this.withExistedFiles = false,
  });
}
