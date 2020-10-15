import 'package:dive/base_state.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation_provider.dart';

class HomeScreen extends StatefulWidget {
  final int qid;
  final bool isGolden;
  final int tabNumber;

  HomeScreen(
      {this.qid = -1,
      this.isGolden = false,
      this.tabNumber = TAB_CHAT_LIST_SCREEN});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    subscribeToLinksStream();
    getLogger().d(initializingHome);
  }

  @override
  void dispose() {
    getLogger().d(disposingHome);
    unsubscribeToLinksStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.qid != -1) {
        NavigationProvider.of(context).setTab(widget.tabNumber);

        NavigationProvider.of(context)
            .currentScreen
            .navigatorState
            .currentState
            .pushNamed(RouterKeys.questionWithAnswerRoute, arguments: {
          'qid': widget.qid,
          'isGolden': widget.isGolden,
        });
      }
    });

    return Consumer<NavigationProvider>(
      builder: (context, provider, child) {
        final bottomNavigationBarItems = provider.screens
            .map((screen) => BottomNavigationBarItem(
                icon: screen.icon, title: Text(screen.title)))
            .toList();

        final screens = provider.screens
            .map(
              (screen) => Offstage(
                offstage: screen != provider.currentScreen,
                child: Navigator(
                  key: screen.navigatorState,
                  onGenerateRoute: screen.onGenerateRoute,
                  initialRoute: screen.initialRoute,
                ),
              ),
            )
            .toList();

        return WillPopScope(
          onWillPop: provider.onWillPop,
          child: Scaffold(
            body: IndexedStack(
              children: screens,
              index: provider.currentTabIndex,
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: bottomNavigationBarItems,
              currentIndex: provider.currentTabIndex,
              onTap: provider.setTab,
            ),
          ),
        );
      },
    );
  }
}
