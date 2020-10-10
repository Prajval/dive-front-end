import 'package:dive/repository/questions_repo.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/screens/ask_question.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/explore.dart';
import 'package:dive/screens/question_answer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../utils/logger.dart';

class TabRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouterKeys.chatListRoute:
        return MaterialPageRoute(
            builder: (_) => ChatListScreen(
                  questionsRepository: GetIt.instance<QuestionsRepository>(),
                ));
        break;

      case RouterKeys.exploreRoute:
        return MaterialPageRoute(
            builder: (_) => ExploreScreen(
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

      case RouterKeys.askQuestionRoute:
        return MaterialPageRoute(
            builder: (_) => AskQuestionScreen(
                  questionsRepository: GetIt.instance<QuestionsRepository>(),
                ));
        break;

      default:
        getLogger().d("Invalid route : " + settings.name);
    }
  }

  static openChatListRoute(BuildContext context,
      {int qid = -1, bool isGolden = false}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        RouterKeys.chatListRoute, (Route<dynamic> route) => false);
    if (qid != -1) {
      openQuestionWithAnswerRoute(context, qid, isGolden);
    }
  }

  static openQuestionWithAnswerRoute(
      BuildContext context, int qid, bool isGolden) {
    Navigator.of(context)
        .pushNamed(RouterKeys.questionWithAnswerRoute, arguments: {
      'qid': qid,
      'isGolden': isGolden,
    });
  }

  static openAskQuestionRoute(BuildContext context) {
    return Navigator.of(context).pushNamed(RouterKeys.askQuestionRoute);
  }

  static openExploreRoute(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
        RouterKeys.exploreRoute, (Route<dynamic> route) => false);
  }
}
