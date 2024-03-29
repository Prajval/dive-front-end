import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/root.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/screens/ask_question.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/screens/question_answer.dart';
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

      case RouterKeys.chatListRoute:
        return MaterialPageRoute(
            builder: (_) => ChatListScreen(
                  questionsRepository: GetIt.instance<QuestionsRepository>(),
                ));
        break;

      case RouterKeys.profileRoute:
        return MaterialPageRoute(
            builder: (_) => ProfileScreen(GetIt.instance<UserRepository>()));
        break;

      case RouterKeys.questionWithAnswerRoute:
        final Map arguments = settings.arguments as Map;
        return MaterialPageRoute(
            builder: (_) => QuestionAnswerScreen(
                  qid: arguments['qid'],
                  questionsRepository: GetIt.instance<QuestionsRepository>(),
                  isGolden: arguments['isGolden'],
                ));
        break;

      case RouterKeys.askQuestionRoute:
        return MaterialPageRoute(
            builder: (_) => AskQuestionScreen(
                  questionsRepository: GetIt.instance<QuestionsRepository>(),
                ));
        break;

      default:
        getLogger().d("Invalid route");
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
    Navigator.of(context).pushNamedAndRemoveUntil(
        RouterKeys.rootRoute, (Route<dynamic> route) => false);
  }

  static openSignInRoute(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        RouterKeys.signInRoute, (Route<dynamic> route) => false);
  }

  static openRegisterRoute(BuildContext context) {
    Navigator.pushNamed(context, RouterKeys.registerRoute);
  }

  static openChatListRoute(BuildContext context,
      {int qid = -1, bool isGolden = false}) {
    if (isUserLoggedIn()) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          RouterKeys.chatListRoute, (Route<dynamic> route) => false);
      if (qid != -1) {
        openQuestionWithAnswerRoute(context, qid, isGolden);
      }
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          RouterKeys.signInRoute, (Route<dynamic> route) => false);
    }
  }

  static openProfileRoute(BuildContext context) {
    Navigator.pushNamed(context, RouterKeys.profileRoute);
  }

  static openQuestionWithAnswerRoute(
      BuildContext context, int qid, bool isGolden) {
    Navigator.pushNamed(context, RouterKeys.questionWithAnswerRoute,
        arguments: {
          'qid': qid,
          'isGolden': isGolden,
        });
  }

  static openAskQuestionRoute(BuildContext context) {
    return Navigator.pushNamed(context, RouterKeys.askQuestionRoute);
  }
}
