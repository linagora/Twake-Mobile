import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/channel_event.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/states/channel_state.dart';

export 'package:twake/events/channel_event.dart';
export 'package:twake/states/channel_state.dart';

abstract class BaseChannelBloc extends Bloc<ChannelsEvent, ChannelState> {
  final CollectionRepository<BaseChannel> repository;
  String selectedParentId;

  BaseChannelBloc({
    this.repository,
    ChannelState initState,
  }) : super(initState);

  @override
  Stream<ChannelState> mapEventToState(ChannelsEvent event) async* {
    yield ChannelsEmpty();
  }
}
