import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

enum AuthStatus { NOT_LOGGED_IN, LOGGED_IN }

class Root extends StatefulWidget {
  final BaseAuth auth;

  Root({this.auth});

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  AuthStatus authStatus;

  @override
  void initState() {
    super.initState();

    getLogger().d(initializingRoot);
    User user = widget.auth.getCurrentUser();
    if (user != null) {
      getLogger().d(userIsNotNull);
      getLogger().d(userIdIs + user.uid);
      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
      });
    } else {
      getLogger().e(errorFetchingUser);
      setState(() {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      });
    }
  }

  @override
  void dispose() {
    getLogger().d(disposingRoot);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (authStatus == AuthStatus.LOGGED_IN) {
      getLogger().d(userIsLoggedIn);
      return ChatListScreen(
        auth: widget.auth,
        questionsRepository: GetIt.instance<QuestionsRepository>(),
      );
    } else {
      getLogger().d(userIsNotLoggedIn);
      return SigninScreen(auth: widget.auth);
    }
  }
}
