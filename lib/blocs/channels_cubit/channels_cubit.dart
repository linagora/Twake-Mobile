import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/channels_state.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/channels_repository.dart';
import 'package:twake/services/service_bundle.dart';

export 'package:twake/models/channel/channel.dart';
export 'package:twake/blocs/channels_cubit/channels_state.dart';

abstract class BaseChannelsCubit extends Cubit<ChannelsState> {
  final ChannelsRepository _repository;

  final _socketIOChannelStream = SocketIOService.instance.resourceStream;
  final _socketIOActivityStream = SocketIOService.instance.resourceStream;

  BaseChannelsCubit({required ChannelsRepository repository})
      : _repository = repository,
        super(ChannelsInitial()) {
    // Set up socketIO listeners
    listenToActivityChanges();
    listentToChannelChanges();
  }

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

  Future<bool> create({
    required String name,
    String? icon,
    String? description,
    required ChannelVisibility visibility,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    var channel = Channel(
      id: now.toString(),
      name: name,
      icon: icon,
      description: description,
      companyId: Globals.instance.companyId!,
      workspaceId: Globals.instance.workspaceId!,
      members: const [],
      lastActivity: now,
      visibility: visibility,
      permissions: const [],
    );
    try {
      channel = await _repository.create(channel: channel);
    } catch (e) {
      Logger().e('Error occured during channel creation:\n$e');
      return false;
    }
    final channels = (state as ChannelsLoadedSuccess).channels;
    final hash = (state as ChannelsLoadedSuccess).hash;

    // Check whether the returned channel did not exist before
    if (!channels.any((c) => c.id == channel.id)) channels.add(channel);

    emit(ChannelsLoadedSuccess(
      channels: channels,
      selected: channel,
      hash: hash + channel.hash,
    ));
    return true;
  }

  Future<bool> edit({
    required Channel channel,
    String? name,
    String? icon,
    String? description,
    ChannelVisibility? visibility,
  }) async {
    int oldHash = channel.hash;

    channel = channel.copyWith(
      name: name,
      icon: icon,
      description: description,
      visibility: visibility,
    );

    try {
      channel = await _repository.edit(channel: channel);
    } catch (e) {
      Logger().e('Error occured during channel update:\n$e');
      return false;
    }

    final channels = (state as ChannelsLoadedSuccess).channels;
    final hash = (state as ChannelsLoadedSuccess).hash;

    int index = channels.indexWhere((c) => c.id == channel.id);

    channels[index] = channel;

    emit(ChannelsLoadedSuccess(
      channels: channels,
      selected: channel,
      hash: hash + channel.hash - oldHash,
    ));

    return true;
  }

  Future<bool> delete({required Channel channel}) async {
    try {
      await _repository.delete(channel: channel);
    } catch (e) {
      Logger().e('Error occured during channel removal:\n$e');
      return false;
    }

    final channels = (state as ChannelsLoadedSuccess).channels;
    final hash = (state as ChannelsLoadedSuccess).hash;

    channels.removeWhere((c) => c.id == channel.id);
    emit(ChannelsLoadedSuccess(
      channels: channels,
      selected: null,
      hash: hash - channel.hash,
    ));

    return true;
  }

  Future<List<Account>> fetchMembers({required Channel channel}) async {
    final members = _repository.fetchMembers(channel: channel);

    return members;
  }

  Future<bool> addMembers({
    required Channel channel,
    required List<String> usersToAdd,
  }) async {
    final oldHash = channel.hash;

    try {
      channel = await _repository.addMembers(
        channel: channel,
        usersToAdd: usersToAdd,
      );
    } catch (e) {
      Logger().e('Error occured while adding members to channel:\n$e');
      return false;
    }
    final channels = (state as ChannelsLoadedSuccess).channels;
    final hash = (state as ChannelsLoadedSuccess).hash;

    emit(ChannelsLoadedSuccess(
      channels: channels,
      selected: channel,
      hash: hash - oldHash + channel.hash,
    ));

    return true;
  }

  Future<bool> removeMembers({
    required Channel channel,
    required List<String> usersToRemove,
  }) async {
    final oldHash = channel.hash;

    try {
      channel = await _repository.removeMembers(
        channel: channel,
        usersToRemove: usersToRemove,
      );
    } catch (e) {
      Logger().e('Error occured while removing members from channel:\n$e');
      return false;
    }
    final channels = (state as ChannelsLoadedSuccess).channels;
    final hash = (state as ChannelsLoadedSuccess).hash;

    emit(ChannelsLoadedSuccess(
      channels: channels,
      selected: channel,
      hash: hash - oldHash + channel.hash,
    ));

    return true;
  }

  void selectChannel({required Channel channel}) {
    Globals.instance.channelIdSet = channel.id;

    final channels = (state as ChannelsLoadedSuccess).channels;
    final hash = (state as ChannelsLoadedSuccess).hash;

    SynchronizationService.instance.subscribeToMessages(channelId: channel.id);

    emit(ChannelsLoadedSuccess(
      channels: channels,
      selected: channel,
      hash: hash,
    ));
  }

  void clearSelection({required Channel channel}) {
    Globals.instance.channelIdSet = null;

    final channels = (state as ChannelsLoadedSuccess).channels;
    final hash = (state as ChannelsLoadedSuccess).hash;

    SynchronizationService.instance
        .unsubscribeFromMessages(channelId: channel.id);

    emit(ChannelsLoadedSuccess(
      channels: channels,
      hash: hash,
    ));
  }

  void listenToActivityChanges() async {
    await for (final change in _socketIOActivityStream) {
      if (state is! ChannelsLoadedSuccess) continue;
      final channels = (state as ChannelsLoadedSuccess).channels;
      var hash = (state as ChannelsLoadedSuccess).hash;
      final selected = (state as ChannelsLoadedSuccess).selected;

      switch (change.action) {
        case ResourceAction.saved:
        case ResourceAction.updated:
          // Extract manually all the required data
          String id = change.resource['id'];
          int lastActivity = change.resource['last_activity'];
          MessageSummary lastMessage =
              MessageSummary.fromJson(change.resource['last_message']);

          final index = channels.indexWhere((c) => c.id == id);

          final changed = channels[index].copyWith(
            lastMessage: lastMessage,
            lastActivity: lastActivity,
          );

          hash = hash - channels[index].hash + changed.hash;

          channels[index] = changed;

          channels.sort((c1, c2) => c2.lastActivity.compareTo(c1.lastActivity));

          emit(ChannelsLoadedSuccess(
            channels: channels,
            hash: hash,
            selected: selected,
          ));

          break;

        default:
          throw Exception('Impossible action on channel activity!');
      }
    }
  }

  void listentToChannelChanges() async {
    await for (final change in _socketIOChannelStream) {
      if (state is! ChannelsLoadedSuccess) continue;
      var selected = (state as ChannelsLoadedSuccess).selected;
      final channels = (state as ChannelsLoadedSuccess).channels;
      switch (change.action) {
        case ResourceAction.saved:
        case ResourceAction.updated:
          final rchannels = await _repository.fetchRemote(
            companyId: Globals.instance.companyId!,
            workspaceId: Globals.instance.workspaceId!,
          );

          if (selected != null) {
            selected = rchannels.firstWhere((c) => c.id == selected!.id);
          }

          emit(ChannelsLoadedSuccess(
            channels: rchannels,
            hash: channels.fold(0, (acc, c) => acc + c.hash),
            selected: selected,
          ));
          break;
        case ResourceAction.deleted:
          // fill up required fields with dummy data
          change.resource['name'] = '';
          change.resource['permissions'] = const [];

          final deleted =
              Channel.fromJson(json: change.resource, jsonify: false);

          _repository.delete(
            channel: deleted,
            syncRemote: false,
          );

          channels.removeWhere((c) => c.id == deleted.id);

          emit(ChannelsLoadedSuccess(
            channels: channels,
            hash: channels.fold(0, (acc, c) => acc + c.hash),
            selected: selected,
          ));
      }
    }
  }
}

class ChannelsCubit extends BaseChannelsCubit {
  @override
  final _socketIOChannelStream =
      SynchronizationService.instance.socketIOChannelsStream;

  @override
  final _socketIOActivityStream =
      SynchronizationService.instance.socketIOChannelsActivityStream;

  ChannelsCubit({ChannelsRepository? repository})
      : super(repository: repository ?? ChannelsRepository());
}

class DirectsCubit extends BaseChannelsCubit {
  @override
  final _socketIOChannelStream =
      SynchronizationService.instance.socketIODirectsStream;

  @override
  final _socketIOActivityStream =
      SynchronizationService.instance.socketIODirectsActivityStream;

  DirectsCubit({ChannelsRepository? repository})
      : super(
          repository: repository == null
              ? ChannelsRepository(endpoint: Endpoint.directs)
              : repository,
        );
}
