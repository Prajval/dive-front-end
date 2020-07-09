import 'package:dive/keys.dart';
import 'package:dive/root_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

enum UserDetailsFetchStatus {
  USER_DETAILS_NOT_LOADED,
  USER_DETAILS_LOADED,
  USER_EMAIL_NOT_VERIFIED
}

class HomePage extends StatefulWidget {
  HomePage(this.auth);

  final Auth auth;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName;
  UserDetailsFetchStatus status =
      UserDetailsFetchStatus.USER_DETAILS_NOT_LOADED;

  void getCurrentUser() {
    widget.auth.getCurrentUser().then((user) {
      if (user != null) {
        _userName = user.displayName;
        status = UserDetailsFetchStatus.USER_DETAILS_LOADED;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    widget.auth.isEmailVerified().then((isEmailVerified) {
      setState(() {
        if (isEmailVerified) {
          print('email verified');
          getCurrentUser();
        } else {
          print('email not verified');
          status = UserDetailsFetchStatus.USER_EMAIL_NOT_VERIFIED;
        }
      });
    }).catchError((error) {
      setState(() {
        print('Fetching email verification status failed');
        getCurrentUser();
      });
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                'Welcome $_userName, We are here to help you!',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: 50,
                child: FlatButton(
                  key: Key(Keys.signOutButton),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    widget.auth
                        .signOut()
                        .then((_) => {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RootPage(auth: widget.auth)),
                                  (Route<dynamic> route) => false)
                            })
                        .catchError((error) {
                      String errorMessage =
                          'Signing out failed. Please try again.';

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Error',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Text('$errorMessage'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Ok'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    });
                  },
                  child: Text('Sign out'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmailVerificationPage() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Email verification'),
        ),
        body: SafeArea(
            child: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                'Your email is not verified.',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                child: FlatButton(
                  key: Key(Keys.verifyEmailButton),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    widget.auth
                        .sendEmailVerification()
                        .then((value) => setState(() {
                              getCurrentUser();
                            }))
                        .catchError((error) {
                      setState(() {
                        String errorMessage =
                            'Sending verification email failed. Please try again.';

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Error',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: Text('$errorMessage'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Ok'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      });
                    });
                  },
                  child: Text('Verify email'),
                ),
              ),
            ],
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    if (status == UserDetailsFetchStatus.USER_EMAIL_NOT_VERIFIED) {
      return buildEmailVerificationPage();
    } else if (status == UserDetailsFetchStatus.USER_DETAILS_LOADED) {
      return buildHomePage();
    } else {
      return buildWaitingScreen();
    }
  }
}
