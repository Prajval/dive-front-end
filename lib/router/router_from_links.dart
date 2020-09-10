import 'package:dive/router/router.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:flutter/cupertino.dart';

class RouterFromLinks {
  static openRouteFor(String link, BuildContext context) {
    if (link.indexOf(RouterKeys.chatListRoute) != -1) {
      if (link.indexOf(BackendRouterKeys.questionIdParameter) == -1) {
        Router.openChatListRoute(context);
      } else {
        String qidArgument = link.substring(
            link.indexOf(BackendRouterKeys.questionIdParameter) +
                BackendRouterKeys.questionIdParameter.length);
        int qid =
            int.parse(qidArgument.substring(qidArgument.indexOf("=") + 1));
        Router.openChatListRoute(context, qid: qid, isGolden: false);
      }
    } else {
      getLogger().e(openingLinkFailed);
      getLogger().e(noRegisteredRoutesForTheLink);
    }
  }
}
