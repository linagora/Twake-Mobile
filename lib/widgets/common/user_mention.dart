import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/models/globals/mentions_cache.dart' as mcache;

class UserMention extends StatelessWidget {
  final String? userId;
  final String username;
  final TextStyle style;

  const UserMention({
    required this.userId,
    required this.username,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final name = mcache.cache[userId ?? ''];
    if (name != null) {
      return Text(name, style: style);
    }
    return userId != null
        ? FutureBuilder(
            future: Get.find<AccountCubit>().fetchStateless(userId: userId!),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.data is Account) {
                final account = (snapshot.data as Account);
                mcache.cache[userId!] = account.fullName;
                return Text(
                  account.fullName,
                  style: style,
                );
              } else {
                return Text(
                  '@' + username,
                  style: style,
                );
              }
            })
        : Text(
            '@' + username,
            style: style,
          );
  }
}
