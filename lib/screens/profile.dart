import 'package:dive/root.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/auth.dart';

enum UserDetailsFetchStatus {
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
  UserDetailsFetchStatus status;

  void getCurrentUser() {
    getLogger().d(fetchingUser);
    User user = widget.auth.getCurrentUser();
    if (user != null) {
      getLogger().d(userIsNotNull);
      _userName = user.displayName;
      setState(() {
        status = UserDetailsFetchStatus.USER_DETAILS_LOADED;
      });
    } else {
      getLogger().d(userIsNull);
      setState(() {
        status = UserDetailsFetchStatus.ERROR_LOADING_USER_DETAILS;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLogger().d(initializingProfileScreen);

    if (widget.auth.isEmailVerified()) {
      getLogger().d(emailIsVerified);
      getCurrentUser();
    } else {
      getLogger().d(emailIsNotVerified);
      setState(() {
        status = UserDetailsFetchStatus.USER_EMAIL_NOT_VERIFIED;
      });
    }
  }

  @override
  void dispose() {
    getLogger().d(disposingProfileScreen);
    super.dispose();
  }

  Widget buildProfileScreen() {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(profileAppBar, context),
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
                welcome + ' $_userName, ' + welcomeMessage,
                style: TextStyle(
                    color: blackTextColor,
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
                  textColor: whiteTextColor,
                  onPressed: () {
                    getLogger().d(initiatingSignOut);
                    widget.auth.signOut().then((_) {
                      {
                        getLogger().d(signOutSuccess);
                        return Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => Root(auth: widget.auth)),
                            (Route<dynamic> route) => false);
                      }
                    }).catchError((error) {
                      getLogger().e(signOutFailed);
                      String errorMessage = signOutFailed;

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                errorTitle,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Text('$errorMessage'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(ok),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    });
                  },
                  child: Text(signOutButton),
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
        appBar: ReusableWidgets.getAppBar(emailVerificationAppBar, context),
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
                emailNotVerified,
                style: TextStyle(
                    color: blackTextColor,
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
                  textColor: appWhiteColor,
                  onPressed: () {
                    getLogger().d(initiatingEmailVerification);
                    widget.auth
                        .sendEmailVerification()
                        .then((value) => setState(() {
                              getLogger().d(emailVerificationSent);
                              getCurrentUser();
                            }))
                        .catchError((error) {
                      setState(() {
                        getLogger().e(failedToSendVerificationEmail);
                        String errorMessage =
                            failedToSendVerificationEmailMessage;

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  errorTitle,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: Text('$errorMessage'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(ok),
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
                  child: Text(verifyEmailButton),
                ),
              ),
            ],
          ),
        )));
  }

  Widget buildErrorLoadingUserDetails() {
    return Scaffold(
        appBar: ReusableWidgets.getAppBar(errorAppBar, context),
        body: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                failedToFetchUserDetails,
                style: TextStyle(
                    color: blackTextColor,
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
      getLogger().d(userEmailIsNotVerified);
      return buildEmailVerificationScreen();
    } else if (status == UserDetailsFetchStatus.USER_DETAILS_LOADED) {
      getLogger().d(userDetailsLoaded);
      return buildProfileScreen();
    } else {
      getLogger().d(errorLoadingUserDetails);
      return buildErrorLoadingUserDetails();
    }
  }
}
