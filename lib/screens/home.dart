import 'package:dive/base_state.dart';
import 'package:dive/router/tab_router.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bottomnavigation/destination.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen> {
  int _currentIndex = 0;

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
    HomeScreenArguments arguments = (ModalRoute.of(context).settings == null)
        ? null
        : (ModalRoute.of(context).settings.arguments);
    _currentIndex = (arguments == null) ? _currentIndex : arguments.tabNumber;

    return Scaffold(
      backgroundColor: appPrimaryColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: allDestinations.map<Widget>((Destination destination) {
            return Navigator(
              onGenerateRoute: TabRouter.generateRoute,
              initialRoute: destination.screen,
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: allDestinations.map((Destination destination) {
          return BottomNavigationBarItem(
              icon: Icon(destination.icon),
              backgroundColor: destination.color,
              title: Text(destination.title));
        }).toList(),
      ),
    );
  }
}

class HomeScreenArguments {
  final int tabNumber;
  Function(BuildContext) callback;

  HomeScreenArguments({this.tabNumber, this.callback});
}
