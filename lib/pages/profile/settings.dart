import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/widgets/common/button_field.dart';
import 'package:twake/widgets/common/switch_field.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:twake/widgets/sheets/draggable_scrollable.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SheetBloc>().add(SetFlow(flow: SheetFlow.profile));
      context
          .read<ProfileBloc>()
          .add(SetProfileFlowStage(ProfileFlowStage.info));
    });
  }

  void _onPanelSlide(double position) {
    if (position < 0.4 && _panelController.isPanelAnimating) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffefeef3),
      child: SlidingUpPanel(
        controller: _panelController,
        onPanelOpened: () => context.read<SheetBloc>().add(SetOpened()),
        onPanelClosed: () => context.read<SheetBloc>().add(SetClosed()),
        onPanelSlide: _onPanelSlide,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        backdropEnabled: true,
        renderPanelSheet: false,
        panel: BlocConsumer<SheetBloc, SheetState>(
          listenWhen: (_, current) =>
              current is SheetShouldOpen || current is SheetShouldClose,
          listener: (context, state) {
            // print('Strange state: $state');
            // _closeKeyboards(context);

            if (state is SheetShouldOpen) {
              if (_panelController.isPanelClosed) {
                _panelController.open();
              }
            } else if (state is SheetShouldClose) {
              if (_panelController.isPanelOpen) {
                _panelController.close();
              }
            }
          },
          buildWhen: (_, current) => current is FlowUpdated,
          builder: (context, state) {
            var sheetFlow = SheetFlow.profile;
            if (state is FlowUpdated) {
              sheetFlow = state.flow;
              return DraggableScrollable(flow: sheetFlow);
            } else {
              return SizedBox();
            }
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(16.0, 42.0, 16.0, 36.0),
              color: Color(0xffefeef3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage all your data in one place',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12.0),
                  ButtonField(
                    image: 'assets/images/gear_blue.png',
                    imageSize: 44.0,
                    title: 'Twake Connect',
                    height: 88.0,
                    titleStyle: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    hasArrow: true,
                    onTap: () {
                      if (_panelController.isPanelOpen) {
                        _panelController.close();
                      } else {
                        _panelController.open();
                      }
                    },
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Twake Connect allows you to edit personal data, manage\nworkspaces as well as manage active participants and\ntheir permissions.',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff939297),
                    ),
                  ),
                  SizedBox(height: 72.0),
                  SwitchField(
                    image: 'assets/images/notifications.png',
                    title: 'Notifications',
                    value: false,
                    isExtended: true,
                    isRounded: true,
                    onChanged: (value) {},
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Allow notifications to stay up-to-date on new messages,\nmeetings and other alerts',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff939297),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  ButtonField(
                    image: 'assets/images/language.png',
                    title: 'Language',
                    titleStyle: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    hasArrow: true,
                    arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                    trailingTitle: 'English',
                    trailingTitleStyle: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: Colors.black.withOpacity(0.1),
                  ),
                  ButtonField(
                    image: 'assets/images/location.png',
                    title: 'Location',
                    titleStyle: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    hasArrow: true,
                    arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                    trailingTitle: 'Paris',
                    trailingTitleStyle: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  ButtonField(
                    image: 'assets/images/support.png',
                    title: 'Customer support',
                    titleStyle: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    hasArrow: true,
                    arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                  ),
                  SizedBox(height: 21.0),
                  GestureDetector(
                    onTap: () => print('Logout'),
                    child: Container(
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffff3b30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
