import 'package:dive/repository/user_repo.dart';
import 'package:dive/root.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/screens/bottom_nav_bar/home.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/screens/register.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../utils/logger.dart';

class Router {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouterKeys.rootRoute:
        return MaterialPageRoute(
            builder: (_) => Root(
                  userRepository: GetIt.instance<UserRepository>(),
                ));
        break;

      case RouterKeys.homeRoute:
        final Map arguments = settings.arguments as Map;
        return MaterialPageRoute(
            builder: (_) => HomeScreen(
                  qid: arguments['qid'],
                  isGolden: arguments['isGolden'],
                ));
        break;

      case RouterKeys.signInRoute:
        return MaterialPageRoute(
            builder: (_) => SigninScreen(GetIt.instance<UserRepository>()));
        break;

      case RouterKeys.registerRoute:
        return MaterialPageRoute(
            builder: (_) => RegisterScreen(
                  userRepo: GetIt.instance<UserRepository>(),
                ));
        break;

      case RouterKeys.profileRoute:
        return MaterialPageRoute(
            builder: (_) => ProfileScreen(GetIt.instance<UserRepository>()));
        break;

      default:
        getLogger().d("Invalid route : " + settings.name);
    }
  }

  static openRootRoute(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        RouterKeys.rootRoute, (Route<dynamic> route) => false);
  }

  static openSignInRoute(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        RouterKeys.signInRoute, (Route<dynamic> route) => false);
  }

  static openRegisterRoute(BuildContext context) {
    Navigator.of(context).pushNamed(RouterKeys.registerRoute);
  }

  static openHomeRoute(BuildContext context,
      {int qid = -1, bool isGolden = false, tabNumber = 0}) {
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        RouterKeys.homeRoute, (Route<dynamic> route) => false,
        arguments: {
          'qid': qid,
          'isGolden': isGolden,
          'tabNumber': tabNumber,
        });
  }

  static openProfileRoute(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .pushNamed(RouterKeys.profileRoute);
  }
}
