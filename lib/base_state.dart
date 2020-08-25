import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:uni_links/uni_links.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  StreamSubscription<String> controller;

  void subscribeToLinksStream() {
    controller = getLinksStream().listen((String link) {
      print(link);
    }, onError: (err) {
      print(err.toString());
    });
  }

  void unsubscribeToLinksStream() {
    controller.cancel();
  }
}
