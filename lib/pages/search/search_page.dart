import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/pages/search/search_settings.dart';
import 'package:twake/pages/search/search_tabbar/search_tabbar.dart';
import 'package:twake/pages/search/search_tabbar_view.dart';
import 'package:twake/utils/debouncer.dart';
import 'package:twake/widgets/common/home_header.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();

  late final AnimationController _animController = AnimationController(
    duration: const Duration(milliseconds: searchAnimationTransitionDelay),
    vsync: this,
  )..forward();

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(50, 0.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _animController,
    curve: Curves.ease,
  ));

  late final Animation<double> _opacityAnimation = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: _animController,
    curve: Curves.ease,
  ));

  late final Animation<Offset> _animatedHeightFromTweenAnimation =
      Tween<Offset>(
    begin: const Offset(0.0, 0.0),
    end: const Offset(0.0, -54),
  ).animate(CurvedAnimation(
    parent: _animController,
    curve: Curves.ease,
  ));

  @override
  void initState() {
    super.initState();

    final searchCubit = Get.find<SearchCubit>();
    final debouncer = Debouncer(delay: searchDebounceDelay);

    searchCubit.fetchUsersBySearchTerm();

    _searchController.text = searchCubit.state.searchTerm;

    _searchController.addListener(() {
      debouncer.run(() {
        searchCubit.onSearchTermChanged(_searchController.text);
      });
    });
  }

  void tapCancel() async {
    await _animController.reverse();
    Get.back();
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Scaffold(
            //backgroundColor: Colors.transparent,
            body: SafeArea(
              child: DefaultTabController(
                length: searchTabsList.length,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Stack(
                    children: [
                      Transform.translate(
                          offset: _animatedHeightFromTweenAnimation.value,
                          child: Opacity(
                              opacity: _opacityAnimation.value,
                              child: HomeHeader())),
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                top: 54 +
                                    _animatedHeightFromTweenAnimation.value.dy),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      right: 50 - _offsetAnimation.value.dx),
                                  child: TwakeSearchTextField(
                                    height: 40,
                                    controller: _searchController,
                                    hintText:
                                        AppLocalizations.of(context)!.search,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Transform.translate(
                                      offset: _offsetAnimation.value,
                                      child: GestureDetector(
                                          onTap: () => tapCancel(),
                                          child: Container(
                                              height: 40,
                                              width: 50,
                                              color: Colors.transparent,
                                              child: Center(
                                                child: Text(
                                                  'Cancel',
                                                ),
                                              )))),
                                )
                              ],
                            ),
                          ),
                          SearchTabBar(tabs: searchTabsList),
                          Divider(
                            thickness: 1,
                            height: 4,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          Expanded(
                              child: Opacity(
                                  opacity: 1.0 - _opacityAnimation.value,
                                  child: SearchTabBarView()))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
