import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs_new/channels_cubit/channels_state.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/channels_repository.dart';
import 'package:twake/services/service_bundle.dart';

export 'package:twake/models/channel/channel.dart';
export 'package:twake/blocs_new/channels_cubit/channels_state.dart';

abstract class BaseChannelsCubit extends Cubit<ChannelsState> {
  final ChannelsRepository _repository;

  BaseChannelsCubit({required ChannelsRepository repository})
      : _repository = repository,
        super(ChannelsInitial());

  void fetch({required String workspaceId}) async {
    emit(ChannelsLoadInProgress());

    final channelsStream = _repository.fetch(
      companyId: Globals.instance.companyId,
      workspaceId: workspaceId,
    );

    await for (final channels in channelsStream) {
      Channel? selected;
      if (this.state is ChannelsLoadedSuccess) {
        selected = (this.state as ChannelsLoadedSuccess).selected;
      }
      emit(ChannelsLoadedSuccess(
        channels: channels,
        selected: selected,
        hash: channels.fold(0, (acc, c) => acc + c.hash),
      ));
    }
  }
}

class ChannelsCubit extends BaseChannelsCubit {
  ChannelsCubit({ChannelsRepository? repository})
      : super(repository: repository ?? ChannelsRepository());
}

class DirectsCubit extends BaseChannelsCubit {
  DirectsCubit({ChannelsRepository? repository})
      : super(
          repository: repository == null
              ? ChannelsRepository(endpoint: Endpoint.directs)
              : repository,
        );
}
