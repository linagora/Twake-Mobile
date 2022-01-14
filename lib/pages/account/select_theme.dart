import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/blocs/theme_cubit/theme_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/repositories/theme_repository.dart';

class SelectTheme extends StatefulWidget {
  SelectTheme({Key? key}) : super(key: key);

  @override
  State<SelectTheme> createState() => _SelectThemeState();
}

class _SelectThemeState extends State<SelectTheme> {
  final themeRep = ThemeRepository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        toolbarHeight: 56,
        title: Text(
          AppLocalizations.of(context)!.appearance,
          style: Theme.of(context)
              .textTheme
              .headline1!
              .copyWith(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 14.0, top: 25),
            child: Column(
              children: [
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: themeList.length,
                  itemBuilder: (context, index) {
                    return themeTile(
                      theme: themeList[index],
                      index: index,
                      length: themeList.length,
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    color: Theme.of(context).colorScheme.secondaryVariant,
                    thickness: 0.3,
                    height: 2,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 8, horizontal: Dim.widthPercent(4)),
                  child: Text(
                    AppLocalizations.of(context)!.appearanceDescription,
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget themeTile({
    required String theme,
    required int index,
    required int length,
  }) {
    return GestureDetector(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: index == 0 ? Radius.circular(12.0) : Radius.circular(0),
              topRight: index == 0 ? Radius.circular(12.0) : Radius.circular(0),
              bottomLeft: index == length - 1
                  ? Radius.circular(12.0)
                  : Radius.circular(0),
              bottomRight: index == length - 1
                  ? Radius.circular(12.0)
                  : Radius.circular(0),
            ),
            color: Theme.of(context).colorScheme.secondaryVariant,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                Text(
                  getThemeLocalizationString(theme: theme, ctx: context),
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 15, fontWeight: FontWeight.normal),
                ),
                Spacer(),
                BlocBuilder<ThemeCubit, ThemeState>(
                  bloc: Get.find<ThemeCubit>(),
                  builder: (context, state) {
                    if (state.themeStatus == ThemeStatus.done) {
                      if (state.theme == theme) {
                        return Icon(
                          Icons.check_circle_rounded,
                          size: 26,
                          color: Theme.of(context).colorScheme.surface,
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                )
              ],
            ),
          ),
        ),
        onTap: () async {
          Get.find<ThemeCubit>().changeTheme(theme: theme);
        });
  }
}

String getThemeLocalizationString(
    {required String theme, required BuildContext ctx}) {
  switch (theme) {
    case 'Light':
      return AppLocalizations.of(ctx)!.light;
    case 'Dark':
      return AppLocalizations.of(ctx)!.dark;
    case 'System':
      return AppLocalizations.of(ctx)!.system;
    default:
      return AppLocalizations.of(ctx)!.system;
  }
}
