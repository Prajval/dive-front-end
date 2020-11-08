import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dive/router/router_from_links.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uni_links/uni_links.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  StreamSubscription<String> deepLinksSubscription;
  GetLinksStreamWrapper getLinksStreamWrapper =
      GetIt.instance<GetLinksStreamWrapper>();
  StreamSubscription internetConnectionChangesSubscription;

  void initialize() {
    deepLinksSubscription =
        getLinksStreamWrapper.getLinksStreamFromLibrary().listen((String link) {
      link = link.substring(BackendRouterKeys.baseRoute.length);
      getLogger().i(openingDeepLink + link);

      RouterFromLinks.openRouteFor(link, context);
    }, onError: (error) {
      getLogger().e(openingLinkFailed);
      getLogger().e(error);
    });

    internetConnectionChangesSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile) {
        getLogger().i(connectedToMobileData);
      } else if (result == ConnectivityResult.wifi) {
        getLogger().i(connectedToWifi);
      } else {
        getLogger().i(notConnectedToTheInternet);
      }
    });
  }

  void close() {
    deepLinksSubscription.cancel();
    internetConnectionChangesSubscription.cancel();
  }
}

class GetLinksStreamWrapper {
  Stream<String> getLinksStreamFromLibrary() {
    return getLinksStream();
  }
}
