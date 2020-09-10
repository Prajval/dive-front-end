import 'dart:async';

import 'package:dive/router/router_from_links.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/utils/logger.dart';
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

      RouterFromLinks.openRouteFor(link, context);
    }, onError: (error) {
      getLogger().e(openingLinkFailed);
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
