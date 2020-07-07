import 'package:dive/auth.dart';
import 'package:dive/home_page.dart';
import 'package:dive/sign_in_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AuthStatus { NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN }

class RootPage extends StatefulWidget {
  final BaseAuth auth;

  RootPage({this.auth});

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
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
      return HomePage(widget.auth);
    } else if (authStatus == AuthStatus.NOT_LOGGED_IN) {
      print('User is not logged in.');
      return SigninPage(auth: widget.auth);
    } else {
      print('User is not logged in yet, loading.');
      return buildWaitingScreen();
    }
  }
}
