import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

enum AuthStatus { NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN }

class Root extends StatefulWidget {
  final BaseAuth auth;

  Root({this.auth});

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  String _userId = "";
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  @override
  void initState() {
    super.initState();

    getLogger().d(initializingRoot);
    widget.auth
        .getCurrentUser()
        .then((user) => setState(() {
              if (user != null) {
                getLogger().d(userIsNotNull);
                _userId = user?.uid;
                getLogger().d(userIdIs + _userId);
              }
              authStatus = user?.uid == null
                  ? AuthStatus.NOT_LOGGED_IN
                  : AuthStatus.LOGGED_IN;
            }))
        .catchError((error) => (setState(() {
              getLogger().e(errorFetchingUser);
              authStatus = AuthStatus.NOT_LOGGED_IN;
            })));
  }

  @override
  void dispose() {
    getLogger().d(disposingRoot);
    super.dispose();
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (authStatus == AuthStatus.LOGGED_IN) {
      getLogger().d(userIsLoggedIn);
      return ChatListScreen(
        auth: widget.auth,
        questionsRepository: GetIt.instance<QuestionsRepository>(),
      );
    } else if (authStatus == AuthStatus.NOT_LOGGED_IN) {
      getLogger().d(userIsNotLoggedIn);
      return SigninScreen(auth: widget.auth);
    } else {
      getLogger().d(loading);
      return buildWaitingScreen();
    }
  }
}
