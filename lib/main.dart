import 'package:dive/repository/local_storage/cache_repo.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/dependencies.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/router/router.dart';
import 'package:dive/router/router_keys.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  getLogger().d(settingUpDependencies);
  await Firebase.initializeApp();
  setUpDependencies();
  await CacheRepo().isCacheReady();
  final firebaseMessaging = FirebaseMessaging();
  firebaseMessaging.requestNotificationPermissions();
  getLogger().d(startingTheApp);
  runApp(DiveApp());
}

class DiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Router.navigatorKey,
      theme: ThemeData(primaryColor: appPrimaryColor),
      color: appWhiteColor,
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.rootRoute,
    );
  }
}
