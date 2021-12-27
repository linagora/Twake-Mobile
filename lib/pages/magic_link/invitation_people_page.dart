import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/magic_link_cubit/invitation_cubit/invitation_cubit.dart';
import 'package:twake/blocs/magic_link_cubit/invitation_cubit/invitation_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/button_text_builder.dart';
import 'package:twake/utils/extensions.dart';

class InvitationPeoplePage extends StatefulWidget {
  const InvitationPeoplePage({Key? key}) : super(key: key);

  @override
  _InvitationPeoplePageState createState() => _InvitationPeoplePageState();
}

class _InvitationPeoplePageState extends State<InvitationPeoplePage> {
  String? _workspaceName;
  final _urlNotifier = ValueNotifier<String>('');
  final invitationCubit = Get.find<InvitationCubit>();

  @override
  void initState() {
    super.initState();
    _workspaceName = Get.arguments;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      invitationCubit.generateNewLink();
    });
  }

  @override
  void dispose() {
    _urlNotifier.dispose();
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

  Widget _buildHeaderViewSection() => Container(
        margin: const EdgeInsets.only(top: 48),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
                maxRadius: 50,
                minRadius: 50,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    imageInvitePeopleHeader_x3,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            )
          ],
        ),
      );

  Widget _buildTitleViewSection() => Container(
        margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              text: TextSpan(children: [
                TextSpan(
                  text: AppLocalizations.of(context)?.inviteToWorkspace ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: _workspaceName ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ]),
            ),
            SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 34),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: AppLocalizations.of(context)
                            ?.inviteToWorkspaceSubtitle1 ??
                        '',
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontSize: 15, fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                    text: _workspaceName ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context)
                            ?.inviteToWorkspaceSubtitle2 ??
                        '',
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontSize: 15, fontWeight: FontWeight.normal),
                  ),
                ]),
              ),
            ),
          ],
        ),
      );

  Widget _buildBodyViewSection() => BlocConsumer<InvitationCubit,
          InvitationState>(
      bloc: invitationCubit,
      listener: (context, state) {
        if (state.status == InvitationStatus.generateLinkSuccess) {
          _urlNotifier.value = state.link;
        }
      },
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.sendMagicLinkToColleagues ?? '',
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildLinkField(),
                  ),
                  SizedBox(width: 8),
                  BlocBuilder<CompaniesCubit, CompaniesState>(
                    bloc: Get.find<CompaniesCubit>(),
                    builder: (context, compState) => GestureDetector(
                      onTap: () => _handleClickOnButtonConfig(state, compState),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 22),
                        decoration: StylesConfig.commonBoxDecoration.copyWith(
                            color:
                                Theme.of(context).colorScheme.secondaryVariant),
                        child: Image.asset(imageConfig,
                            width: 16,
                            height: 16,
                            color: (compState is CompaniesLoadSuccess &&
                                    compState.selected.canReGenerateMagicLink)
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(context)
                                    .colorScheme
                                    .secondaryVariant),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              ButtonTextBuilder(
                Key('button_share_invitation_link'),
                onButtonClick: () => _handleClickOnButtonShareLink(),
                backgroundColor: Theme.of(context).colorScheme.surface,
              )
                  .setWidth(double.infinity)
                  .setHeight(50)
                  .setText(
                      AppLocalizations.of(context)?.shareInvitationLink ?? '')
                  .setTextStyle(
                    Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 17, fontWeight: FontWeight.normal),
                  )
                  .build(),
              SizedBox(height: 54),
              Text(AppLocalizations.of(context)?.sendInvitationByEmail ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 17, fontWeight: FontWeight.w600)),
              SizedBox(height: 16),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  ButtonTextBuilder(
                    Key('button_invite_by_email'),
                    onButtonClick: () => _handleClickOnButtonInviteByEmail(),
                    backgroundColor:
                        Theme.of(context).colorScheme.surface.withOpacity(0.25),
                  )
                      .setWidth(double.infinity)
                      .setHeight(50)
                      .setText(
                          AppLocalizations.of(context)?.inviteByEmail ?? '')
                      .setTextStyle(Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontSize: 17, fontWeight: FontWeight.w600))
                      .build(),
                  Container(
                    margin: const EdgeInsets.only(right: 15),
                    child: Image.asset(
                      imageSendEmail,
                      width: 20,
                      height: 20,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  )
                ],
              )
            ],
          ),
        );
      });

  Widget _buildLinkField() => GestureDetector(
        onTap: () => _handleClickOnLink(),
        child: Container(
          decoration: StylesConfig.commonBoxDecoration
              .copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
          padding:
              const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 30),
          child: Row(
            children: [
              Image.asset(
                imageLink,
                width: 16,
                height: 16,
                color: Theme.of(context).colorScheme.surface,
              ),
              SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder(
                    valueListenable: _urlNotifier,
                    builder:
                        (BuildContext context, String value, Widget? child) {
                      return Text(value.overflow,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headline2!
                              .copyWith(fontSize: 16));
                    }),
              )
            ],
          ),
        ),
      );

  _handleClickOnButtonConfig(
      InvitationState state, CompaniesState companiesState) async {
    if (!(companiesState is CompaniesLoadSuccess) ||
        !companiesState.selected.canReGenerateMagicLink) return;
    invitationCubit.resetState();
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        enableDrag: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.0),
                topRight: Radius.circular(14.0))),
        builder: (ctxModal) {
          return BlocBuilder<InvitationCubit, InvitationState>(
              bloc: invitationCubit,
              builder: (ctx, state) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Image.asset(imagePathCancel,
                                        width: 24, height: 24))),
                            Text(
                                AppLocalizations.of(context)?.generateNewLink ??
                                    '',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    )),
                            SizedBox(height: 12),
                            Text(
                                AppLocalizations.of(context)
                                        ?.generateNewLinkSubtitle ??
                                    '',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                textAlign: TextAlign.center),
                            SizedBox(height: 16),
                            _buildLinkField(),
                            (state.status ==
                                    InvitationStatus.generateLinkSuccess)
                                ? Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    child: Row(children: [
                                      Image.asset(imageValid,
                                          width: 14, height: 14),
                                      SizedBox(width: 8),
                                      Expanded(
                                          child: Text(
                                        AppLocalizations.of(context)
                                                ?.newLinkGenerated ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .copyWith(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ))
                                    ]))
                                : SizedBox.shrink()
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ButtonTextBuilder(
                            Key('button_generate_new_link'),
                            onButtonClick: () =>
                                _handleClickOnButtonGenerateLink(),
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                          )
                              .setWidth(double.infinity)
                              .setHeight(50)
                              .setText(AppLocalizations.of(context)
                                      ?.generateNewLink ??
                                  '')
                              .setTextStyle(Theme.of(context)
                                  .textTheme
                                  .headline1!
                                  .copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal))
                              .build(),
                        )
                      ],
                    ),
                  ));
        });
  }

  _handleClickOnButtonShareLink() async {
    if (_urlNotifier.value.isEmpty) return;
    final sharedContent =
        AppLocalizations.of(context)?.joinMeOnTwake(_urlNotifier.value) ?? '';
    await Share.share(sharedContent);
  }

  _handleClickOnButtonInviteByEmail() {
    NavigatorService.instance
        .navigateToInvitationPeopleEmail(_urlNotifier.value);
  }

  _handleClickOnLink() {
    Clipboard.setData(new ClipboardData(text: _urlNotifier.value)).then((_) {
      Get.snackbar('', '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
          margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          animationDuration: Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 1500),
          icon: Image.asset(imageCopiedClipboard, width: 40, height: 40),
          titleText: SizedBox.shrink(),
          messageText: Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: Text(
                AppLocalizations.of(context)!.invitationCopiedToClipboard,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 15, fontWeight: FontWeight.normal)),
          ),
          boxShadows: [
            BoxShadow(
              blurRadius: 16,
              color: Color.fromRGBO(0, 0, 0, 0.24),
            )
          ]);
    });
  }

  _handleClickOnButtonGenerateLink() {
    invitationCubit.generateNewLink();
  }
}
