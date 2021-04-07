import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:twake/blocs/companies_bloc/companies_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/pages/feed/channels.dart';
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
    Channels(),
    Settings(),
  ];
  var _selectedIndex = 0;

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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      body: SlidingUpPanel(
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
            var sheetFlow = SheetFlow.addChannel;
            if (state is FlowUpdated) {
              sheetFlow = state.flow;
              return DraggableScrollable(flow: sheetFlow);
            } else {
              return SizedBox();
            }
          },
        ),
        body: Center(
          child: _widgets.elementAt(_selectedIndex),
        ),

      ),
    );
  }
}

