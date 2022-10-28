import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/file/user.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/channels_repository.dart';
import 'package:twake/services/socketio_service.dart';
import 'package:twake/services/synchronization_service.dart';

part 'online_status_state.dart';

class OnlineStatusCubit extends Cubit<OnlineStatusState> {
  final _socketIOResourceStream = SocketIOService.instance.resourceStream;
  final _socketIOOnlineUserStream = SocketIOService.instance.onlineUserStream;
  late ChannelsRepository channelsRepository;
  late Timer _timer;
  OnlineStatusCubit({ChannelsRepository? repository})
      : super(OnlineStatusState(onlineStatus: OnlineStatus.off)) {
    if (repository == null) {
      repository = ChannelsRepository();
    }
    channelsRepository = repository;
    listenToResourceOnlineStatus();
    listenToOnlineUserStream();
    getOnlineStatusHttp();
    startTimer();
  }

  void getOnlineStatusWebSocket({List<Account> accounts = const []}) async {
    if (accounts.isNotEmpty) {
      final List<String> ids = [];
      accounts.forEach((account) {
        ids.add(account.id);
      });
      SynchronizationService.instance.getOnlineStatus(ids);
      return;
    }
    final List<String> ids = [];
    // TODO: do it only for users which are displayed on the screen
    final users = Get.find<DirectsCubit>().getAllDirectUsers();
    users.forEach((channelId, value) {
      // not add users from directs where more then 2 users, except chat with yourself
      if (value.length > 1)
        value.removeWhere((userId) => userId == Globals.instance.userId);

      if (value.length == 1) ids.add(value.first);
    });
    if (users.isNotEmpty) SynchronizationService.instance.getOnlineStatus(ids);
  }

  void getOnlineStatusHttp() async {
    final Map<String, List<User>> res =
        await channelsRepository.fetchUsersOnlineStatus();

    if (res.isNotEmpty)
      emit(OnlineStatusState(
          onlineStatus: OnlineStatus.success, channelUsers: res));
  }

  void setOnlineStatus() async {
    SynchronizationService.instance.setOnlineStatus();
  }

  List<dynamic> isConnected(String channelId) {
    // for now not work with directs where more then 2 users
    List<dynamic> data = List<dynamic>.filled(2, [], growable: false);

    if (state.channelUsers.containsKey(channelId)) {
      final List<User> listUser = state.channelUsers[channelId]!;
      if (listUser.length > 1)
        listUser.removeWhere((user) => user.id == Globals.instance.userId);

      if (listUser.length == 1) {
        final bool isConnected =
            listUser.every((element) => element.isConnected == true);
        data[0] = isConnected;
        final int? lastSeen = listUser
            .firstWhere((element) => element.lastSeen != null,
                orElse: () => dummyUser())
            .lastSeen;
        data[1] = lastSeen;

        //  DateTime dateTime =
        //      DateTime.fromMillisecondsSinceEpoch(lastSeen!).toLocal();
        //  DateTime justNow = DateTime.now().subtract(Duration(minutes: 10));
        //  final diff = dateTime.difference(justNow);

        state.onlineUsers.containsKey(listUser[0].id)
            ? data[0] = state.onlineUsers[listUser[0].id]
            : null;

        return data;
      }
    }
    data[0] = false;
    data[1] = 946670400000;
    return data;
  }

  Future<void> listenToResourceOnlineStatus() async {
    await for (final resourceStream in _socketIOResourceStream) {
      if (resourceStream.type == ResourceType.userOnlineStatus) {
        final users = {...state.onlineUsers};
        (resourceStream.resource['online'] as List<dynamic>).forEach((element) {
          users.containsKey(element['user_id'])
              ? users['user_id'] = element['is_online']
              : users.addAll({element['user_id']: element['is_online']});
        });
        emit(state.copyWith(newOnlineUsers: users));
      }
    }
  }

  void startTimer() {
    // TODO: need to create global app timer
    const oneT = const Duration(minutes: 5);
    _timer = Timer.periodic(
      oneT,
      (Timer timer) {
        setOnlineStatus();
        getOnlineStatusHttp();
      },
    );
  }

  Future<void> listenToOnlineUserStream() async {
    await for (final onlineUserStream in _socketIOOnlineUserStream) {
      final users = {...state.onlineUsers};
      users.containsKey(onlineUserStream[0])
          ? users[onlineUserStream[0]] = onlineUserStream[1]
          : users.addAll({onlineUserStream[0]: onlineUserStream[1]});

      emit(state.copyWith(newOnlineUsers: users));
    }
  }

  User dummyUser() {
    return User(
        id: '',
        email: '',
        fullName: '',
        lastActivity: 0,
        verified: false,
        deleted: false,
        lastSeen: 946670400000);
  }
}
