import 'package:dive/base_state.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/router/router.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum UserDetailsFetchStatus {
  USER_DETAILS_LOADED,
  USER_EMAIL_NOT_VERIFIED,
  ERROR_LOADING_USER_DETAILS,
}

class ProfileScreen extends StatefulWidget {
  ProfileScreen(this.userRepository);

  final UserRepository userRepository;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends BaseState<ProfileScreen> {
  User user;
  UserDetailsFetchStatus status;

  void loadCurrentUser() {
    getLogger().d(fetchingUser);
    user = widget.userRepository.getCurrentUser();
    if (user != null) {
      getLogger().d(userIsNotNull);

      if (widget.userRepository.isEmailVerified()) {
        getLogger().d(emailIsVerified);
        status = UserDetailsFetchStatus.USER_DETAILS_LOADED;
      } else {
        getLogger().d(emailIsNotVerified);
        status = UserDetailsFetchStatus.USER_EMAIL_NOT_VERIFIED;
      }
    } else {
      getLogger().d(userIsNull);
      status = UserDetailsFetchStatus.ERROR_LOADING_USER_DETAILS;
    }
  }

  @override
  void initState() {
    super.initState();
    subscribeToLinksStream();
    getLogger().d(initializingProfileScreen);

    loadCurrentUser();
  }

  @override
  void dispose() {
    getLogger().d(disposingProfileScreen);
    unsubscribeToLinksStream();
    super.dispose();
  }

  Widget buildProfileScreen() {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(profileAppBar, context),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            ListView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: appPrimaryColor,
                    foregroundColor: appWhiteColor,
                    child: Text(_getInitials(user.displayName)),
                  ),
                  title: Text(
                    user.displayName,
                    style: TextStyle(
                        color: blackTextColor,
                        fontSize: 20,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    user.email,
                    style: TextStyle(
                      color: blackTextColor,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: appPrimaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  child: FlatButton(
                    key: Key(Keys.signOutButton),
                    color: appPrimaryColor,
                    textColor: whiteTextColor,
                    onPressed: () {
                      getLogger().d(initiatingSignOut);
                      widget.userRepository.signOut().then((_) {
                        getLogger().d(signOutSuccess);
                        Router.openRootRoute(context);
                      }).catchError((error) {
                        getLogger().e(signOutFailed);
                        String errorMessage = signOutFailed;

                        ReusableWidgets.displayDialog(
                            context, errorTitle, errorMessage, ok, () {});
                      });
                    },
                    child: Text(
                      signOutButton,
                      style: TextStyle(
                        color: whiteTextColor,
                        fontSize: 20,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => showEmailVerificationDialog());
    if (status == UserDetailsFetchStatus.ERROR_LOADING_USER_DETAILS) {
      getLogger().d(errorLoadingUserDetails);
      return buildErrorLoadingUserDetails();
    } else {
      getLogger().d(userDetailsLoaded);
      return buildProfileScreen();
    }
  }

  void showEmailVerificationDialog() {
    if (status == UserDetailsFetchStatus.USER_EMAIL_NOT_VERIFIED) {
      getLogger().d(userEmailIsNotVerified);

      ReusableWidgets.displayDialog(
          context, emailVerification, emailNotVerified, verifyEmailButton, () {
        _sendEmailVerification();
      });
    }
  }

  void _sendEmailVerification() {
    getLogger().d(initiatingEmailVerification);
    widget.userRepository.sendEmailVerification().then((value) {
      getLogger().d(emailVerificationSentToUser);
      ReusableWidgets.displayDialog(
          context, success, emailVerificationSent, ok, () {});
    }).catchError((error) {
      getLogger().e(failedToSendVerificationEmail);
      String errorMessage = failedToSendVerificationEmailMessage;

      ReusableWidgets.displayDialog(
          context, errorTitle, errorMessage, ok, () {});
    });
  }

  String _getInitials(String fullName) => fullName.isNotEmpty
      ? fullName.trim().split(' ').map((l) => l[0]).take(2).join()
      : '';
}
