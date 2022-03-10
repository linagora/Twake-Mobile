import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/channel_file_cubit/channel_file_state.dart';
import 'package:twake/models/attachment/attachment.dart';
import 'package:twake/models/channel/channel_file.dart';
import 'package:twake/repositories/messages_repository.dart';

class ChannelFileCubit extends Cubit<ChannelFileState> {
  late final MessagesRepository _messageRepository;

  ChannelFileCubit({MessagesRepository? messagesRepository})
      : super(ChannelFileState()) {
    if (messagesRepository == null) {
      messagesRepository = MessagesRepository();
    }
    _messageRepository = messagesRepository;
  }

  void loadFilesInChannel(String channelId) async {
    final streamMessages = _messageRepository.fetch(
      channelId: channelId,
      withExistedFiles: true,
    );
    await for (var messages in streamMessages) {
      if(messages.isNotEmpty) {
        List<ChannelFile> listFiles = [];
        messages.reversed.forEach((message) {
          final childFileList = message.files?.map((element) {
            if (element is String && element.isNotEmpty) {
                  return ChannelFile(element, message.sender);
                } else if (element is Attachment) {
                  return ChannelFile(element.metadata.externalId.id, message.sender);
                }
                return ChannelFile('', '');
              }).toList() ?? [];
          listFiles.addAll(childFileList);
        });
        final lastList = listFiles.where((element) => element.fileId.isNotEmpty).toList();
        emit(state.copyWith(
          newStatus: ChannelFileStatus.finished,
          newListFiles: lastList,
        ));
      } else {
        emit(state.copyWith(
          newStatus: ChannelFileStatus.finished,
          newListFiles: [],
        ));
      }
    }
  }
}
