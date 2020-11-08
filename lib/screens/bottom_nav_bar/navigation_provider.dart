import 'package:dive/repository/questions_repo.dart';
import 'package:dive/router/bottom_nav_router.dart';
import 'package:dive/router/router.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/screens/bottom_nav_bar/nav_bar_screen.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/explore.dart';
import 'package:dive/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

const TAB_CHAT_LIST_SCREEN = 0;
const TAB_EXPLORE_SCREEN = 1;

class NavigationProvider extends ChangeNotifier {
  /// Shortcut method for getting [NavigationProvider].
  static NavigationProvider of(BuildContext context) =>
      Provider.of<NavigationProvider>(context, listen: false);

  int _currentScreenIndex = TAB_CHAT_LIST_SCREEN;

  int get currentTabIndex => _currentScreenIndex;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    getLogger().i('Generating route using central navigator: ${settings.name}');

    return Router.generateRoute(settings);
  }

  final Map<int, NavBarScreen> _screens = {
    TAB_CHAT_LIST_SCREEN: NavBarScreen(
      title: 'Chat list',
      child: ChatListScreen(
        questionsRepository: GetIt.instance<QuestionsRepository>(),
      ),
      icon: Icon(Icons.chat),
      initialRoute: RouterKeys.chatListRoute,
      navigatorState: GlobalKey<NavigatorState>(),
      onGenerateRoute: (settings) {
        getLogger().i('Generating route using tab navigator: ${settings.name}');
        return BottomNavRouter.generateRoute(settings);
      },
    ),
    TAB_EXPLORE_SCREEN: NavBarScreen(
      title: 'Explore',
      child: ExploreScreen(
        questionsRepository: GetIt.instance<QuestionsRepository>(),
      ),
      icon: Icon(Icons.explore),
      initialRoute: RouterKeys.exploreRoute,
      navigatorState: GlobalKey<NavigatorState>(),
      onGenerateRoute: (settings) {
        getLogger().i('Generating route using tab navigator: ${settings.name}');
        return BottomNavRouter.generateRoute(settings);
      },
    ),
  };

  List<NavBarScreen> get screens => _screens.values.toList();

  NavBarScreen get currentScreen => _screens[_currentScreenIndex];

  /// Set currently visible tab.
  void setTab(int tab) {
    if (tab != currentTabIndex) {
      _currentScreenIndex = tab;
      notifyListeners();
    }
  }

  /// Provide this to [WillPopScope] callback.
  Future<bool> onWillPop() async {
    final currentNavigatorState = currentScreen.navigatorState.currentState;

    if (currentNavigatorState.canPop()) {
      currentNavigatorState.pop();
      return false;
    } else {
      if (currentTabIndex != TAB_CHAT_LIST_SCREEN) {
        setTab(TAB_CHAT_LIST_SCREEN);
        notifyListeners();
        return false;
      } else {
        return true;
      }
    }
  }
}
