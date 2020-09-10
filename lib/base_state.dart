import 'dart:async';

import 'package:dive/utils/logger.dart';
import 'package:dive/router/router.dart';
import 'package:dive/router/router_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:uni_links/uni_links.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  StreamSubscription<String> controller;
  GetLinksStreamWrapper getLinksStreamWrapper =
      GetIt.instance<GetLinksStreamWrapper>();

  void subscribeToLinksStream() {
    controller =
        getLinksStreamWrapper.getLinksStreamFromLibrary().listen((String link) {
      link = link.substring(BackendRouterKeys.baseRoute.length);
      getLogger().i(openingDeepLink + link);

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
        getLogger().e(openingDeepLinkFailed);
        getLogger().e(noRegisteredRoutesForTheOpenedDeepLink);
      }
    }, onError: (error) {
      getLogger().e(openingDeepLinkFailed);
      getLogger().e(error);
    });
  }

  void unsubscribeToLinksStream() {
    controller.cancel();
  }
}

class GetLinksStreamWrapper {
  Stream<String> getLinksStreamFromLibrary() {
    return getLinksStream();
  }
}
