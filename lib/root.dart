import 'package:dive/repository/user_repo.dart';
import 'package:dive/router/router.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/push_notification/push_notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Root extends StatelessWidget {
  final UserRepository userRepository;

  Root({this.userRepository});

  @override
  Widget build(BuildContext context) {
    getLogger().i(openedRoot);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userRepository.getCurrentUser() == null) {
        Router.openSignInRoute(context);
      } else {
        Router.openHomeRoute(context);
      }
    });
    GetIt.instance<PushNotificationService>().initialise();
    return Scaffold(
      backgroundColor: appWhiteColor,
    );
  }
}
