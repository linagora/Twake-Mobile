import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/channel_file_cubit/channel_file_state.dart';
import 'package:twake/models/attachment/attachment.dart';
import 'package:twake/models/channel/channel.dart';
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

  void loadFilesInChannel(Channel channel) async {
    final streamMessages = _messageRepository.fetch(
      channelId: channel.id,
      workspaceId: channel.isDirect ? 'direct' : null,
    );
    await for (var messages in streamMessages) {
      if (messages.isNotEmpty) {
        List<ChannelFile> listFiles = [];
        messages.reversed.forEach((message) async {
          if (message.subtype == MessageSubtype.deleted) return;

          // Find all files in main chat
          final childFileList = getChannelFileList(
                  files: message.files,
                  sender: message.sender,
                  updatedAt: message.createdAt)
              .where((element) => element.fileId.isNotEmpty)
              .toList();
          listFiles.addAll(childFileList);

          // Find all files inside reply thread
          final streamMessagesInThread = _messageRepository.fetch(
            channelId: channel.id,
            threadId: message.id,
            withExistedFiles: true,
            workspaceId: channel.isDirect ? 'direct' : null,
          );
          await for (var threadMessList in streamMessagesInThread) {
            if (threadMessList.length > 1) {
              // Every thread starts/contains [message] in list
              List<ChannelFile> listFilesThread = [];
              threadMessList
                  .getRange(1, threadMessList.length)
                  .forEach((messInThread) {
                final filesInThread = getChannelFileList(
                  files: messInThread.files,
                  sender: messInThread.sender,
                  updatedAt: messInThread.createdAt,
                );
                listFilesThread.addAll(filesInThread.where((tFile) =>
                    tFile.fileId.isNotEmpty &&
                    listFiles
                        .every((mFile) => (mFile.fileId != tFile.fileId))));
              });
              listFiles.addAll(listFilesThread);
            }
          }
          // Files are sorted chronologically
          listFiles.sort((m1, m2) => m2.createdAt.compareTo(m1.createdAt));
          emit(state.copyWith(
            newStatus: ChannelFileStatus.finished,
            newListFiles: listFiles,
          ));
        });
      } else {
        emit(state.copyWith(
          newStatus: ChannelFileStatus.finished,
          newListFiles: [],
        ));
      }
    }
  }

  List<ChannelFile> getChannelFileList(
      {required List<dynamic>? files,
      required String sender,
      String? fileName,
      required int updatedAt}) {
    return files?.map((element) {
          if (element is String && element.isNotEmpty) {
            return ChannelFile(
                fileId: element,
                senderName: sender,
                fileName: fileName ?? "",
                createdAt: updatedAt);
          } else if (element is Attachment) {
            return ChannelFile(
                fileId: element.metadata.externalId.id,
                senderName: sender,
                fileName: fileName ?? "",
                createdAt: updatedAt);
          }
          return ChannelFile(
              fileId: '', senderName: '', fileName: '', createdAt: 0);
        }).toList() ??
        [];
  }
}
