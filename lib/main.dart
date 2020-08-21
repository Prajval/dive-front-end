import 'package:dive/root.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/dependencies.dart';
import 'package:dive/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  getLogger().d(settingUpDependencies);
  await Firebase.initializeApp();
  setUpDependencies();
  getLogger().d(startingTheApp);
  runApp(DiveApp());
}

class DiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: appPrimaryColor),
      color: appWhiteColor,
      home: new Root(auth: GetIt.instance<BaseAuth>()),
    );
  }
}
