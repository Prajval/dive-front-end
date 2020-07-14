import 'package:dive/utils/keys.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/widgets.dart';
import 'package:dive/root.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/auth.dart';

enum UserDetailsFetchStatus {
  USER_DETAILS_NOT_LOADED,
  USER_DETAILS_LOADED,
  USER_EMAIL_NOT_VERIFIED,
  ERROR_LOADING_USER_DETAILS,
}

class ProfileScreen extends StatefulWidget {
  ProfileScreen(this.auth);

  final Auth auth;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName;
  UserDetailsFetchStatus status =
      UserDetailsFetchStatus.USER_DETAILS_NOT_LOADED;

  void getCurrentUser() {
    print('getting current user');
    widget.auth.getCurrentUser().then((user) {
      if (user != null) {
        print('user not null');
        _userName = user.displayName;
        status = UserDetailsFetchStatus.USER_DETAILS_LOADED;
      } else {
        print('user null');
        status = UserDetailsFetchStatus.ERROR_LOADING_USER_DETAILS;
      }
    }).catchError((error) {
      print('Fetching user details failed with the following error :\n');
      print('$error');
      status = UserDetailsFetchStatus.ERROR_LOADING_USER_DETAILS;
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

  Widget buildProfileScreen() {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar('Profile', context),
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
                  color: appPrimaryColor,
                  textColor: Colors.white,
                  onPressed: () {
                    widget.auth
                        .signOut()
                        .then((_) => {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Root(auth: widget.auth)),
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

  Widget buildEmailVerificationScreen() {
    return Scaffold(
        appBar: ReusableWidgets.getAppBar('Email verification', context),
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
                  color: appPrimaryColor,
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

  Widget buildErrorLoadingUserDetails() {
    return Scaffold(
        appBar: ReusableWidgets.getAppBar('Error', context),
        body: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                'Failed to fetch user details. Please try again after some time.',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (status == UserDetailsFetchStatus.USER_EMAIL_NOT_VERIFIED) {
      return buildEmailVerificationScreen();
    } else if (status == UserDetailsFetchStatus.USER_DETAILS_LOADED) {
      return buildProfileScreen();
    } else if (status == UserDetailsFetchStatus.ERROR_LOADING_USER_DETAILS) {
      return buildErrorLoadingUserDetails();
    } else {
      return buildWaitingScreen();
    }
  }
}
