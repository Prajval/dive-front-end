import 'package:dive/utils/auth.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/sign_in.dart';
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

    widget.auth
        .getCurrentUser()
        .then((user) => setState(() {
              if (user != null) {
                _userId = user?.uid;
              }
              authStatus = user?.uid == null
                  ? AuthStatus.NOT_LOGGED_IN
                  : AuthStatus.LOGGED_IN;
            }))
        .catchError((error) => (setState(() {
              authStatus = AuthStatus.NOT_LOGGED_IN;
            })));
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
      print('User $_userId is logged in.');
      return ChatListScreen(
        auth: widget.auth,
        questionsRepository: GetIt.instance<QuestionsRepository>(),
      );
    } else if (authStatus == AuthStatus.NOT_LOGGED_IN) {
      print('User is not logged in.');
      return SigninScreen(auth: widget.auth);
    } else {
      print('User is not logged in yet, loading.');
      return buildWaitingScreen();
    }
  }
}
