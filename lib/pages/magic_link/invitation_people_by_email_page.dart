import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/magic_link_cubit/invitation_email_cubit/invitation_email_cubit.dart';
import 'package:twake/blocs/magic_link_cubit/invitation_email_cubit/invitation_email_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/deeplink/email_state.dart';
import 'package:twake/models/deeplink/email_status.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/button_text_builder.dart';

class InvitationPeopleEmailPage extends StatefulWidget {
  const InvitationPeopleEmailPage({Key? key}) : super(key: key);

  @override
  _InvitationPeopleEmailPageState createState() =>
      _InvitationPeopleEmailPageState();
}

class _InvitationPeopleEmailPageState extends State<InvitationPeopleEmailPage> {
  String? invitationUrl;
  late List<TextEditingController> _textEditingControllers;
  final ScrollController _scrollController = ScrollController();
  final invitationEmailCubit = Get.find<InvitationEmailCubit>();

  @override
  void initState() {
    super.initState();
    invitationUrl = Get.arguments;
    _textEditingControllers = [];
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      invitationEmailCubit.addEmail('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0)),
            child: BlocConsumer<InvitationEmailCubit, InvitationEmailState>(
                bloc: invitationEmailCubit,
                listener: (context, state) {
                  if (state.status == InvitationEmailStatus.addEmailSuccess) {
                    _textEditingControllers.add(TextEditingController());
                  } else if (state.status ==
                      InvitationEmailStatus.sendEmailSuccess) {
                    _textEditingControllers
                        .removeWhere((element) => element.text.trim().isEmpty);
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      _buildHeaderViewSection(state),
                      Divider(
                        height: 0.5,
                        color: Theme.of(context).colorScheme.secondaryVariant,
                      ),
                      Expanded(child: _buildBodyViewSection(state)),
                    ],
                  );
                })),
      ),
    );
  }

  Widget _buildHeaderViewSection(InvitationEmailState state) {
    return Container(
      color: Theme.of(context).colorScheme.secondaryVariant,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          !_isSentEmailSuccessfully(state)
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
          Align(
              alignment: Alignment.center,
              child: Container(
                child: Text(AppLocalizations.of(context)?.inviteUsers ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 17)),
              )),
          !_isSentEmailSuccessfully(state)
              ? BlocBuilder(
                  bloc: Get.find<CompaniesCubit>(),
                  builder: (ctx, companyState) {
                    return Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            if (state.status ==
                                InvitationEmailStatus.inProcessing) return;
                            _handleClickOnButtonSend();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(14)),
                                  color: Theme.of(context).colorScheme.surface),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 20),
                              child: Text(
                                  AppLocalizations.of(context)
                                          ?.sendButton
                                          .toUpperCase() ??
                                      '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600))),
                        ));
                  })
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildBodyViewSection(InvitationEmailState state) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildInvitationSentHeader(state),
            ..._buildListEmail(state),
            _buildButtonAddMoreMember(state),
            _buildInvitationSentActions(state),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationSentHeader(InvitationEmailState state) =>
      _isSentEmailSuccessfully(state)
          ? Container(
              margin: const EdgeInsets.only(
                  top: 32, bottom: 16, left: 65, right: 65),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)?.invitationSent ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  SizedBox(height: 12),
                  Image.asset(
                    imageInvitationSent,
                    fit: BoxFit.contain,
                    color: Theme.of(context).colorScheme.surface,
                  )
                ],
              ))
          : SizedBox.shrink();

  List<Widget> _buildListEmail(InvitationEmailState state) {
    List<TextEditingController> sentEmailControllers;
    if (state.status == InvitationEmailStatus.sendEmailSuccess ||
        state.status == InvitationEmailStatus.sendEmailSuccessShowAll) {
      sentEmailControllers = _textEditingControllers.toList();
      return state.listEmailState
          .map((emailState) => _buildEmailItem(
              sentEmailControllers.firstWhere((controller) =>
                  emailState.email.trim() == controller.text.trim()),
              emailState))
          .toList();
    } else {
      sentEmailControllers = _textEditingControllers.toList();
      return sentEmailControllers
          .map((controller) => _buildEmailItem(
              controller,
              state.listEmailState.firstWhere(
                  (emailState) =>
                      emailState.email.trim() == controller.text.trim(),
                  orElse: () => EmailState.init())))
          .toList();
    }
  }

  Widget _buildEmailItem(
          TextEditingController editingController, EmailState state) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: TextField(
            controller: editingController,
            keyboardType: TextInputType.emailAddress,
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontSize: 17, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
                filled: true,
                isDense: true,
                contentPadding:
                    EdgeInsets.only(top: 16, bottom: 16, right: 42, left: 24),
                fillColor: Theme.of(context).colorScheme.secondaryVariant,
                errorText: null,
                hintText: AppLocalizations.of(context)?.addEmailAddress ?? '',
                hintStyle: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontSize: 15, fontWeight: FontWeight.normal),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: state.status != EmailStatus.init
                    ? Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 12),
                        child: Image.asset(
                            state.status == EmailStatus.valid
                                ? imageValid
                                : imageInvalid,
                            width: 18,
                            height: 18),
                      )
                    : SizedBox.shrink())),
      );

  Widget _buildButtonAddMoreMember(InvitationEmailState state) =>
      !_isSentEmailSuccessfully(state)
          ? GestureDetector(
              onTap: () => _handleClickOnButtonInviteMore(),
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Theme.of(context).colorScheme.secondaryVariant),
                child: Row(
                  children: [
                    Image.asset(
                      imageAddBlueBg,
                      width: 24,
                      height: 24,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.inviteAnotherMember ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            )
          : SizedBox.shrink();

  Widget _buildInvitationSentActions(InvitationEmailState state) =>
      _isSentEmailSuccessfully(state)
          ? Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              child: Column(
                children: [
                  (state.cachedSentSuccessEmails.length > emailListDisplayLimit)
                      ? TextButton(
                          onPressed: () => _handleClickOnButtonShowMore(),
                          child: Text(
                            AppLocalizations.of(context)?.showMoreInvites(
                                    (state.cachedSentSuccessEmails.length -
                                            emailListDisplayLimit)
                                        .toString()) ??
                                '',
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontSize: 17, fontWeight: FontWeight.w500),
                          ))
                      : SizedBox.shrink(),
                  SizedBox(height: 14),
                  ButtonTextBuilder(
                    Key('button_go_to_main_screen'),
                    onButtonClick: () =>
                        NavigatorService.instance.navigateToHome(),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  )
                      .setText(
                          AppLocalizations.of(context)?.goToMainScreen ?? '')
                      .setHeight(50)
                      .setBorderRadius(BorderRadius.all(Radius.circular(14)))
                      .build()
                ],
              ),
            )
          : SizedBox.shrink();

  void _handleClickOnButtonInviteMore() async {
    invitationEmailCubit.addEmail('');
    Timer(Duration(milliseconds: 100), () async {
      await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    });
  }

  void _handleClickOnButtonSend() {
    final allEmails =
        _textEditingControllers.map((e) => e.text.trim()).toList();
    invitationEmailCubit.sendEmails(allEmails);
  }

  void _handleClickOnButtonShowMore() {
    invitationEmailCubit.showFullSentSuccessEmail();
  }

  bool _isSentEmailSuccessfully(InvitationEmailState state) {
    return state.status == InvitationEmailStatus.sendEmailSuccess ||
        state.status == InvitationEmailStatus.sendEmailSuccessShowAll;
  }
}
