import 'package:dive/repository/user_repo.dart';
import 'package:dive/root.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/screens/home.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/screens/register.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

      case RouterKeys.homeRoute:
        return MaterialPageRoute(builder: (_) => HomeScreen());
        break;

      default:
        getLogger().d("Invalid route : " + settings.name);
    }
  }

  static bool isUserLoggedIn() {
    UserRepository userRepository = GetIt.instance<UserRepository>();
    User user = userRepository.getCurrentUser();
    if (user != null) {
      getLogger().d(userIsNotNull);
      getLogger().d(userIdIs + user.uid);
      return true;
    } else {
      getLogger().e(errorFetchingUser);
      return false;
    }
  }

  static openRootRoute(BuildContext context) {
    navigatorKey.currentState.pushNamedAndRemoveUntil(
        RouterKeys.rootRoute, (Route<dynamic> route) => false);
  }

  static openSignInRoute(BuildContext context) {
    navigatorKey.currentState.pushNamedAndRemoveUntil(
        RouterKeys.signInRoute, (Route<dynamic> route) => false);
  }

  static openRegisterRoute(BuildContext context) {
    navigatorKey.currentState.pushNamed(RouterKeys.registerRoute);
  }

  static openProfileRoute(BuildContext context) {
    navigatorKey.currentState.pushNamed(RouterKeys.profileRoute);
  }

  static openHomeRoute(BuildContext context) {
    return navigatorKey.currentState.pushNamedAndRemoveUntil(
        RouterKeys.homeRoute, (Route<dynamic> route) => false);
  }
}
