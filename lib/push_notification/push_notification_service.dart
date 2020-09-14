import 'dart:io';

import 'package:dive/push_notification/push_notification_keys.dart';
import 'package:dive/router/router.dart';
import 'package:dive/router/router_from_links.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

enum NotificationType {
  APP_FOREGROUND,
  APP_BACKGROUND,
  APP_CLOSED,
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Future initialise() async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        getLogger().i(receivedPushNotificationWhenAppOpen);
        getLogger().i("onMessage: $message");

        handleNotification(message, NotificationType.APP_FOREGROUND);
      },
      onLaunch: (Map<String, dynamic> message) async {
        getLogger().i(receivedPushNotificationWhenAppIsClosed);
        getLogger().i("onLaunch: $message");

        handleNotification(message, NotificationType.APP_CLOSED);
      },
      onResume: (Map<String, dynamic> message) async {
        getLogger().i(receivedPushNotificationWhenAppIsInBackground);
        getLogger().i("onResume: $message");

        handleNotification(message, NotificationType.APP_BACKGROUND);
      },
    );
  }

  Future<String> getFcmToken() {
    return _fcm.getToken();
  }

  void handleNotification(
      Map<String, dynamic> message, NotificationType notificationType) {
    try {
      String notificationTitle, notificationBody, route = "";

      if (Platform.isIOS) {
        notificationTitle = message[PushNotificationKeys.aps]
                [PushNotificationKeys.alert][PushNotificationKeys.title]
            .toString();
        notificationBody = message[PushNotificationKeys.aps]
                [PushNotificationKeys.alert][PushNotificationKeys.body]
            .toString();

        if (message[PushNotificationBackendKeys.routeLink] != null) {
          route = message[PushNotificationBackendKeys.routeLink].toString();
        }
      } else {
        notificationTitle = message[PushNotificationKeys.notification]
                [PushNotificationKeys.title]
            .toString();
        notificationBody = message[PushNotificationKeys.notification]
                [PushNotificationKeys.body]
            .toString();

        if (message[PushNotificationKeys.data] != null &&
            message[PushNotificationKeys.data]
                    [PushNotificationBackendKeys.routeLink] !=
                null) {
          route = message[PushNotificationKeys.data]
                  [PushNotificationBackendKeys.routeLink]
              .toString();
        }
      }

      if (notificationType == NotificationType.APP_FOREGROUND) {
        showNewNotificationDialog(notificationTitle, notificationBody, route);
      } else if (notificationType == NotificationType.APP_CLOSED) {
        if (route.isNotEmpty) {
          RouterFromLinks.openRouteFor(
              route, Router.navigatorKey.currentState.overlay.context);
        }
      } else {
        if (route.isNotEmpty) {
          RouterFromLinks.openRouteFor(
              route, Router.navigatorKey.currentState.overlay.context);
        }
      }
    } catch (e) {
      Router.openRootRoute(Router.navigatorKey.currentState.overlay.context);
      getLogger().e(failedToOpenNotification);
      getLogger().e(e.toString());
    }
  }

  void showNewNotificationDialog(
      String notificationTitle, String notificationBody, String link) {
    showDialog(
        context: Router.navigatorKey.currentState.overlay.context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              notificationTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(notificationBody),
            actions: <Widget>[
              FlatButton(
                child: link.isEmpty ? Text(ok) : Text(takeMeThere),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (link.isNotEmpty) {
                    RouterFromLinks.openRouteFor(link, context);
                  }
                },
              )
            ],
          );
        });
  }
}
