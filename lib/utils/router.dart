import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/register_repo.dart';
import 'package:dive/screens/ask_question.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/screens/question_answer.dart';
import 'package:dive/screens/register.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:dive/utils/router_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'auth.dart';
import 'logger.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouterKeys.rootRoute:
        return MaterialPageRoute(
            builder: (_) => isUserLoggedIn()
                ? ChatListScreen(
                    auth: GetIt.instance<BaseAuth>(),
                    questionsRepository: GetIt.instance<QuestionsRepository>(),
                  )
                : SigninScreen(auth: GetIt.instance<BaseAuth>()));
        break;

      case RouterKeys.signInRoute:
        return MaterialPageRoute(
            builder: (_) => SigninScreen(auth: GetIt.instance<BaseAuth>()));
        break;

      case RouterKeys.registerRoute:
        return MaterialPageRoute(
            builder: (_) => RegisterScreen(
                  registerRepo: GetIt.instance<RegisterRepository>(),
                ));
        break;

      case RouterKeys.chatListRoute:
        return MaterialPageRoute(
            builder: (_) => ChatListScreen(
                  auth: GetIt.instance<BaseAuth>(),
                  questionsRepository: GetIt.instance<QuestionsRepository>(),
                ));
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

      case RouterKeys.profileRoute:
        return MaterialPageRoute(
            builder: (_) => ProfileScreen(GetIt.instance<BaseAuth>()));
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
    Auth auth = GetIt.instance<BaseAuth>();
    User user = auth.getCurrentUser();
    if (user != null) {
      getLogger().d(userIsNotNull);
      getLogger().d(userIdIs + user.uid);
      return true;
    } else {
      getLogger().e(errorFetchingUser);
      return false;
    }
  }
}
