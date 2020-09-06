import 'dart:io';

import 'package:dive/utils/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
      },
      onLaunch: (Map<String, dynamic> message) async {
        getLogger().i(receivedPushNotificationWhenAppIsInBackground);
        getLogger().i("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        getLogger().i(receivedPushNotificationWhenAppIsClosed);
        getLogger().i("onResume: $message");
      },
    );
  }

  Future<String> getFcmToken() {
    return _fcm.getToken();
  }
}
