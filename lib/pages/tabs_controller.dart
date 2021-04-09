import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:twake/blocs/companies_bloc/companies_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/pages/feed/feed.dart';
import 'package:twake/pages/profile/settings.dart';
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/widgets/sheets/draggable_scrollable.dart';

class TabsController extends StatefulWidget {
  @override
  _TabsControllerState createState() => _TabsControllerState();
}

class _TabsControllerState extends State<TabsController> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final PanelController _panelController = PanelController();
  final List<Widget> _widgets = [
    Feed(),
    Settings(),
  ];
  var _selectedIndex = 0;
  var _isSelectWorkspaceFlow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompaniesBloc>().add(ReloadCompanies());
    });
  }

  _onPanelSlide(double position) {
    if (position < 0.4 && _panelController.isPanelAnimating) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: Color(0xffefeef3),
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<SheetBloc, SheetState>(
        listenWhen: (_, current) =>
            current is SheetShouldOpen || current is SheetShouldClose,
        listener: (context, state) {
          // print('Strange state: $state');
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
        buildWhen: (_, current) {
          print('Current state: $current');
          return current is FlowUpdated;
        },
        builder: (context, state) {
          var sheetFlow = SheetFlow.addChannel;
          if (state is FlowUpdated) {
            sheetFlow = state.flow;
            _isSelectWorkspaceFlow = sheetFlow == SheetFlow.selectWorkspace;
          }

          return SlidingUpPanel(
            controller: _panelController,
            onPanelOpened: () => context.read<SheetBloc>().add(SetOpened()),
            onPanelClosed: () => context.read<SheetBloc>().add(SetClosed()),
            onPanelSlide: _onPanelSlide,
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height *
                (_isSelectWorkspaceFlow ? 0.5 : 0.9),
            backdropEnabled: true,
            renderPanelSheet: false,
            panel: state is FlowUpdated
                ? SafeArea(
                    child: DraggableScrollable(flow: sheetFlow),
                  )
                : SizedBox(),
            body: IndexedStack(index: _selectedIndex, children: _widgets),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        backgroundColor: Color(0xfff7f7f7),
        selectedItemColor: Color(0xff004dff),
        currentIndex: _selectedIndex,
        onTap: (index) {
          FocusScope.of(context).requestFocus(FocusNode());
          context.read<SheetBloc>()
            ..add(CloseSheet())
            ..add(SetFlow(
              flow: index != 0 ? SheetFlow.profile : SheetFlow.addChannel,
            ));

          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            activeIcon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Image.asset('assets/images/channels_active.png'),
            ),
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Image.asset('assets/images/channels_inactive.png'),
            ),
            label: 'Channels',
          ),
          BottomNavigationBarItem(
            activeIcon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Image.asset('assets/images/profile_active.png'),
            ),
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Image.asset('assets/images/profile_inactive.png'),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
