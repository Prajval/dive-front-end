import 'package:dive/router/router.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/router/tab_router.dart';
import 'package:dive/utils/logger.dart';
import 'package:flutter/cupertino.dart';

class RouterFromLinks {
  static openRouteFor(String link, BuildContext context) {
    var uri = Uri.parse(link);

    for (final currentPath in uri.pathSegments) {
      if (RouterKeys.chatListRoute.contains(currentPath)) {
        if (uri.queryParameters
            .containsKey(BackendRouterKeys.questionIdParameter)) {
          Router.openRootRoute(context, (context) {
            TabRouter.openChatListRoute(context,
                qid: int.parse(
                    uri.queryParameters[BackendRouterKeys.questionIdParameter]),
                isGolden: false);
          }, homeScreenTabNumber: 0);
        } else {
          Router.openRootRoute(context, (context) {});
        }
      } else if (RouterKeys.rootRoute.contains(currentPath)) {
        Router.openRootRoute(context, (context) {});
      } else {
        getLogger().e(openingLinkFailed);
        getLogger().e(noRegisteredRoutesForTheLink);
      }
    }
  }
}
