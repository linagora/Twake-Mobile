import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/lenguage_cubit/language_cubit.dart';
import 'package:twake/repositories/language_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectLanguage extends StatefulWidget {
  SelectLanguage({Key? key}) : super(key: key);

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  @override
  Widget build(BuildContext context) {
    final languageCode = LanguageRepository().languages;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF004DFF),
          ),
        ),
        
        toolbarHeight: 56,
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.language,
          style: TextStyle(fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Color(0xffefeef3),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 14.0, top: 25),
            child: ListView.separated(
              itemCount: languageCode.length,
              itemBuilder: (context, index) {
                return languageTile(
                  languageCode: languageCode[index],
                  index: index,
                  length: languageCode.length,
                  context: context,
                );
              },
              separatorBuilder: (context, index) => Divider(
                color: Color(0xffefeef3),
                thickness: 0.3,
                height: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget languageTile({
    required String languageCode,
    required int index,
    required int length,
    required BuildContext context,
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
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                Text(
                  getLenguageString(
                      languageCode: languageCode, context: context),
                  style: TextStyle(fontSize: 20),
                ),
                Spacer(),
                BlocBuilder<LanguageCubit, LanguageState>(
                  bloc: Get.find<LanguageCubit>(),
                  builder: (context, state) {
                    if (state is NewLanguage) {
                      if (state.language == languageCode) {
                        return Icon(
                          Icons.check_circle_rounded,
                          size: 26,
                          color: Color(0xFF004DFF),
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
          Get.find<LanguageCubit>().changeLanguage(language: "$languageCode");
          Get.updateLocale(Locale("$languageCode"));
        });
  }

  String getLenguageString(
      {required String languageCode, required BuildContext context}) {
    final String language;

    switch (languageCode) {
      case 'en':
        language = AppLocalizations.of(context)!.english;
        break;
      case 'es':
        language = AppLocalizations.of(context)!.spanish;
        break;
      default:
        language = 'English';
    }
    return language;
  }
}
