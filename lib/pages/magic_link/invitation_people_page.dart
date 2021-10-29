import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:twake/config/image_path.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/button_text_builder.dart';

class InvitationPeoplePage extends StatefulWidget {
  const InvitationPeoplePage({Key? key}) : super(key: key);

  @override
  _InvitationPeoplePageState createState() => _InvitationPeoplePageState();
}

class _InvitationPeoplePageState extends State<InvitationPeoplePage> {

  String? workspaceName;
  final urlNotifier = ValueNotifier<String>('https://twake.app/0834J0...');

  @override
  void initState() {
    super.initState();
    workspaceName = Get.arguments;
  }

  @override
  void dispose() {
    urlNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderViewSection(),
              _buildTitleViewSection(),
              _buildBodyViewSection(),
            ],
          ),
        ),
      ),
    );
  }

  _buildHeaderViewSection() => Container(
    margin: const EdgeInsets.only(top: 48),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Icon(
                Icons.arrow_back_ios,
                color: const Color(0xff004dff),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Image.asset(imageInvitePeopleHeader, width: 100, height: 100)
        )
      ],
    ),
  );

  _buildTitleViewSection() => Container(
    margin: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)?.inviteToWorkspace ?? '',
              style: StylesConfig.commonTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              workspaceName ?? '',
              style: StylesConfig.commonTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff004dff)
              ),
            )
          ]
        ),
        SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)?.inviteToWorkspaceSubtitle1 ?? '',
                  style: StylesConfig.commonTextStyle.copyWith(
                    fontSize: 15
                  ),
                ),
                TextSpan(
                  text: workspaceName ?? '',
                  style: StylesConfig.commonTextStyle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  ),
                ),
                TextSpan(
                  text: AppLocalizations.of(context)?.inviteToWorkspaceSubtitle2 ?? '',
                  style: StylesConfig.commonTextStyle.copyWith(
                      fontSize: 15,
                  ),
                ),
              ]
            ),
          ),
        ),
      ],
    ),
  );

  _buildBodyViewSection() => Container(
    margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.sendMagicLinkToColleagues ?? '',
          style: StylesConfig.commonTextStyle.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: StylesConfig.commonBoxDecoration,
                padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 30),
                child: Row(
                  children: [
                    Image.asset(imageLink, width: 16, height: 16),
                    SizedBox(width: 12),
                    ValueListenableBuilder(
                      valueListenable: urlNotifier,
                      builder: (BuildContext context, String value, Widget? child) {
                        return Text(
                          value,
                          style: StylesConfig.commonTextStyle.copyWith(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.6)
                          ),
                        );
                      }
                    )
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () => _handleClickOnButtonCopy(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                decoration: StylesConfig.commonBoxDecoration,
                child: Image.asset(imageCopy, width: 20, height: 20)))
          ],
        ),
        SizedBox(height: 8),
        ButtonTextBuilder(
            Key('button_share_invitation_link'),
            onButtonClick: () => _handleClickOnButtonShareLink())
          .setWidth(double.infinity)
          .setHeight(50)
          .setText(AppLocalizations.of(context)?.shareInvitationLink ?? '')
          .setTextStyle(StylesConfig.commonTextStyle.copyWith(fontSize: 17, color: Colors.white))
          .build(),
        SizedBox(height: 54),
        Text(
          AppLocalizations.of(context)?.sendInvitationByEmail ?? '',
          style: StylesConfig.commonTextStyle.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            ButtonTextBuilder(
                Key('button_invite_by_email'),
                onButtonClick: () => _handleClickOnButtonInviteByEmail())
              .setWidth(double.infinity)
              .setHeight(50)
              .setBackgroundColor(Color.fromRGBO(0, 77, 255, 0.08))
              .setText(AppLocalizations.of(context)?.inviteByEmail ?? '')
              .setTextStyle(StylesConfig.commonTextStyle.copyWith(fontSize: 17, color: Color(0xff004dff), fontWeight: FontWeight.w600))
              .build(),
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: Image.asset(imageSendEmail, width: 20, height: 20),
            )
          ],
        )
      ],
    ),
  );

  _handleClickOnButtonCopy() async {
    Clipboard.setData(new ClipboardData(text: urlNotifier.value)).then((_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, MediaQuery.of(context).size.height - 110),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1500),
          content: Row(
            children: [
              Image.asset(imageCopiedClipboard, width: 40, height: 40),
              SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.invitationCopiedToClipboard,
                  style: StylesConfig.commonTextStyle.copyWith(fontSize: 15)),
            ],
          ),
        ),
      );
    });
  }

  _handleClickOnButtonShareLink() async {
    await Share.share(urlNotifier.value);
  }

  _handleClickOnButtonInviteByEmail() {
    NavigatorService.instance.navigateToInvitationPeopleEmail(urlNotifier.value);
  }
}
