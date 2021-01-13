import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:twake/blocs/auth_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/companies_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/blocs/notification_bloc.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/blocs/threads_bloc.dart';
import 'package:twake/blocs/workspaces_bloc.dart';
import 'package:twake/config/dimensions_config.dart';
// import 'package:twake/pages/auth_page.dart';
import 'package:twake/pages/routes.dart';
import 'package:twake/pages/web_auth_page.dart';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthBloc>(context).add(AuthInitialize());
  }

  Widget buildSplashScreen() {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: Dim.heightPercent(13),
          height: Dim.heightPercent(13),
          child: Lottie.asset(
            'assets/animations/splash.json',
            animate: true,
            repeat: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (ctx, state) {
        if (state is AuthInitializing) {
          return buildSplashScreen();
        }
        if (state is Unauthenticated) {
          return WebAuthPage();
        }
        if (state is Authenticated) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ProfileBloc>(
                create: (_) => ProfileBloc(state.initData.profile),
                lazy: false,
              ),
              BlocProvider<NotificationBloc>(create: (_) => NotificationBloc()),
              BlocProvider<CompaniesBloc>(
                create: (ctx) => CompaniesBloc(state.initData.companies),
              ),
              BlocProvider<WorkspacesBloc>(create: (ctx) {
                return WorkspacesBloc(
                  repository: state.initData.workspaces,
                  companiesBloc: BlocProvider.of<CompaniesBloc>(ctx),
                );
              }),
              BlocProvider<ChannelsBloc>(create: (ctx) {
                return ChannelsBloc(
                  repository: state.initData.channels,
                  workspacesBloc: BlocProvider.of<WorkspacesBloc>(ctx),
                  notificationBloc: BlocProvider.of<NotificationBloc>(ctx),
                );
              }),
              BlocProvider<DirectsBloc>(create: (ctx) {
                return DirectsBloc(
                  repository: state.initData.directs,
                  companiesBloc: BlocProvider.of<CompaniesBloc>(ctx),
                  notificationBloc: BlocProvider.of<NotificationBloc>(ctx),
                );
              }),
              BlocProvider<MessagesBloc<ChannelsBloc>>(
                create: (ctx) {
                  return MessagesBloc<ChannelsBloc>(
                    repository: state.initData.messages,
                    channelsBloc: BlocProvider.of<ChannelsBloc>(ctx),
                    notificationBloc: BlocProvider.of<NotificationBloc>(ctx),
                  );
                },
                lazy: false,
              ),
              BlocProvider<MessagesBloc<DirectsBloc>>(
                create: (ctx) {
                  return MessagesBloc<DirectsBloc>(
                    repository: state.initData.messages,
                    channelsBloc: BlocProvider.of<DirectsBloc>(ctx),
                    notificationBloc: BlocProvider.of<NotificationBloc>(ctx),
                  );
                },
                lazy: false,
              ),
              BlocProvider<ThreadsBloc<ChannelsBloc>>(
                create: (ctx) {
                  return ThreadsBloc<ChannelsBloc>(
                    repository: state.initData.threads,
                    messagesBloc:
                        BlocProvider.of<MessagesBloc<ChannelsBloc>>(ctx),
                    notificationBloc: BlocProvider.of<NotificationBloc>(ctx),
                  );
                },
                lazy: false,
              ),
              BlocProvider<ThreadsBloc<DirectsBloc>>(
                create: (ctx) {
                  return ThreadsBloc<DirectsBloc>(
                    repository: state.initData.threads,
                    messagesBloc:
                        BlocProvider.of<MessagesBloc<DirectsBloc>>(ctx),
                    notificationBloc: BlocProvider.of<NotificationBloc>(ctx),
                  );
                },
                lazy: false,
              ),
            ],
            child: Navigator(
              initialRoute: Routes.main,
              onGenerateRoute: (settings) =>
                  Routes.onGenerateRoute(settings.name),
            ),
          );
        } else // is Authenticating
          return buildSplashScreen();
      },
    );
  }
}
