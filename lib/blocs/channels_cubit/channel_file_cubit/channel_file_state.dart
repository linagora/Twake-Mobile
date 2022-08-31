import 'package:equatable/equatable.dart';
import 'package:twake/models/channel/channel_file.dart';

enum ChannelFileStatus { init, loading, finished }

class ChannelFileState with EquatableMixin {
  final ChannelFileStatus channelFileStatus;
  final List<ChannelFile> listFiles;

  const ChannelFileState({
    this.channelFileStatus = ChannelFileStatus.init,
    this.listFiles = const [],
  });

  ChannelFileState copyWith({
    ChannelFileStatus? newStatus,
    List<ChannelFile>? newListFiles,
  }) {
    return ChannelFileState(
      channelFileStatus: newStatus ?? this.channelFileStatus,
      listFiles: newListFiles ?? this.listFiles,
    );
  }

  @override
  List<Object?> get props => [channelFileStatus, listFiles];
}
